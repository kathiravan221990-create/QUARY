-- Quarry hardening (QUARY LEDGER project). Same Users/Roles shape as CP NEXUS.
-- Access level comes from app_metadata.qc_role (server-controlled): administrator | owner | employee.
-- administrator + owner = full access; employee = daily entry, no allowed-IP list, no user management.

create table if not exists public.qc_roles (
  role_id text primary key, name text not null,
  is_admin boolean not null default false, is_super boolean not null default false,
  active boolean not null default true, sort_order int not null default 100,
  created_at timestamptz not null default now());
insert into public.qc_roles (role_id,name,is_admin,is_super,sort_order) values
  ('administrator','Administrator',true,true,5),
  ('owner','Owner',true,false,10),
  ('employee','Employee',false,false,20)
on conflict (role_id) do nothing;

create table if not exists public.qc_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null, display_name text,
  role_id text not null references public.qc_roles(role_id),
  active boolean not null default true, must_change_password boolean not null default false,
  last_login timestamptz, created_at timestamptz not null default now(), created_by text);

-- existing user becomes the Administrator
update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data,'{}'::jsonb) || '{"qc_role":"administrator"}'::jsonb
 where email = 'kathiravan221990@gmail.com';
insert into public.qc_users (user_id, username, display_name, role_id, created_by)
 select id, 'administrator', 'Administrator', 'administrator', 'setup' from auth.users where email='kathiravan221990@gmail.com'
on conflict (user_id) do nothing;

create or replace function public.qc_role() returns text language sql stable as
$$ select auth.jwt() -> 'app_metadata' ->> 'qc_role' $$;

do $$
declare t text; p record;
begin
  for t in select tablename from pg_tables where schemaname='public' and tablename like 'qc\_%' loop
    for p in select policyname from pg_policies where schemaname='public' and tablename=t loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    if t in ('qc_allowed_ips') then
      execute format('create policy full_only on public.%I for all to authenticated using (public.qc_role() in (''administrator'',''owner'')) with check (public.qc_role() in (''administrator'',''owner''))', t);
    elsif t in ('qc_roles','qc_users') then
      execute format('create policy read_all on public.%I for select to authenticated using (public.qc_role() in (''administrator'',''owner'',''employee''))', t);
      execute format('create policy admin_write on public.%I for all to authenticated using (public.qc_role()=''administrator'') with check (public.qc_role()=''administrator'')', t);
    else
      execute format('create policy staff_all on public.%I for all to authenticated using (public.qc_role() in (''administrator'',''owner'',''employee'')) with check (public.qc_role() in (''administrator'',''owner'',''employee''))', t);
    end if;
  end loop;
end $$;

-- records last login for the signed-in user (called by the app after login)
create or replace function public.qc_touch_login() returns void language sql security definer set search_path = public as
$$ update public.qc_users set last_login = now() where user_id = auth.uid() $$;
revoke all on function public.qc_touch_login() from public, anon;
grant execute on function public.qc_touch_login() to authenticated;

-- lets the login screen show the role for a typed username (returns the role name only)
create or replace function public.qc_role_lookup(u text) returns text language sql stable security definer set search_path = public, auth as
$$ select q.role_id from public.qc_users q join auth.users a on a.id = q.user_id
   where q.active and (q.username = lower(trim(u)) or lower(a.email) = lower(trim(u)) or lower(a.email) = lower(trim(u)) || '@quary.invalid') limit 1 $$;
revoke all on function public.qc_role_lookup(text) from public;
grant execute on function public.qc_role_lookup(text) to anon, authenticated;

-- the Edge Function (service_role) needs table privileges too
do $$ declare t text; begin
  for t in select tablename from pg_tables where schemaname='public' and tablename like 'qc\_%' loop
    execute format('grant all on public.%I to service_role', t);
  end loop;
end $$;
grant usage on schema public to service_role;

-- a person clears their own "must change password" flag after choosing a new password
create or replace function public.qc_clear_must_change() returns void language sql security definer set search_path = public as
$$ update public.qc_users set must_change_password = false where user_id = auth.uid() $$;
revoke all on function public.qc_clear_must_change() from public, anon;
grant execute on function public.qc_clear_must_change() to authenticated;
