-- ============================================================
-- 1. NEW TABLES: Expenses & Hitachi
-- ============================================================
create table if not exists public.qc_expenses (
  id uuid primary key,
  quarry text,
  entry_date date,
  entry_time text,
  expense_type text,
  custom_type text,
  amount numeric,
  notes text,
  entered_by text,
  created_at timestamptz default now()
);

create table if not exists public.qc_hitachi_entries (
  id uuid primary key,
  quarry text,
  entry_date date,
  entry_month text,
  entry_time text,
  vendor_name text,
  start_time text,
  close_time text,
  hours_used numeric,
  hourly_rate numeric,
  total numeric,
  pay_mode text,
  pay_mode_other text,
  status text,
  amount_paid numeric,
  entered_by text,
  last_payment_date date,
  last_payment_time text,
  receipt_data text,
  receipt_name text,
  created_at timestamptz default now()
);

-- ============================================================
-- 2. NEW COLUMNS on existing tables (payment receipt tracking)
-- ============================================================
alter table public.qc_purchase_entries
  add column if not exists last_payment_date date,
  add column if not exists last_payment_time text,
  add column if not exists receipt_data text,
  add column if not exists receipt_name text;

alter table public.qc_sale_entries
  add column if not exists last_payment_date date,
  add column if not exists last_payment_time text,
  add column if not exists receipt_data text,
  add column if not exists receipt_name text;

-- ============================================================
-- 3. ENABLE ROW LEVEL SECURITY on every qc_ table
--    (access control is handled in-app via the Employee/Owner
--    login screen, not Supabase Auth, so we allow full access
--    to the anon/authenticated roles to preserve current behavior)
-- ============================================================
do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'qc_transports',
      'qc_vehicles',
      'qc_rate_matrix',
      'qc_sale_master',
      'qc_permits',
      'qc_purchase_entries',
      'qc_sale_entries',
      'qc_allowed_ips',
      'qc_expenses',
      'qc_hitachi_entries'
    ])
  loop
    execute format('alter table if exists public.%I enable row level security;', t);
    execute format('drop policy if exists "allow_all_anon" on public.%I;', t);
    execute format(
      'create policy "allow_all_anon" on public.%I for all to anon, authenticated using (true) with check (true);',
      t
    );
  end loop;
end $$;
