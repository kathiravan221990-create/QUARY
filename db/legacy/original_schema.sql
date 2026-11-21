-- ============================================================
-- QUARRY CONSOLE — ORIGINAL SCHEMA
-- Reconstructed to match exactly what the app reads/writes today.
-- Safe to re-run: every statement uses "if not exists".
-- ============================================================

-- Master data: transports (lorry owners) and their vehicles
create table if not exists public.qc_transports (
  id uuid primary key,
  quarry text,
  name text,
  created_at timestamptz default now()
);

create table if not exists public.qc_vehicles (
  id uuid primary key,
  quarry text,
  transport_id uuid,
  vehicle_name text,
  created_at timestamptz default now()
);

-- Wheel/Unit rate matrix (also doubles as the settings row for
-- default permit amount and Hitachi hourly rate, via the
-- is_permit_setting / is_hitachi_rate flags)
create table if not exists public.qc_rate_matrix (
  id uuid primary key,
  quarry text,
  wheel numeric,
  unit numeric,
  gravel_amount numeric,
  redsoil_amount numeric,
  is_permit_setting boolean,
  permit_amount numeric,
  is_hitachi_rate boolean,
  hourly_rate numeric,
  created_at timestamptz default now()
);

-- Sale rate master: order/lorry/rate/rental combos
create table if not exists public.qc_sale_master (
  id uuid primary key,
  quarry text,
  order_name text,
  lorry_name text,
  rate numeric,
  rental numeric,
  combined_rate numeric,
  created_at timestamptz default now()
);

-- Permit inventory
create table if not exists public.qc_permits (
  id uuid primary key,
  quarry text,
  permit_no text,
  date_added date,
  load_count int default 0,
  status text,           -- 'active' | 'exhausted'
  created_at timestamptz default now()
);

-- Purchase entries (Daily Entry → Purchase tab)
create table if not exists public.qc_purchase_entries (
  id uuid primary key,
  quarry text,
  entry_date date,
  entry_time text,
  permit_no text,
  load_number int,
  mt text,
  transport_name text,
  vehicle_name text,
  vehicle_no text,
  product text,
  wheel numeric,
  unit numeric,
  pay_mode text,
  pay_mode_other text,
  load_amount numeric,
  permit_amount numeric,
  total numeric,
  status text,            -- 'Paid' | 'Pending'
  amount_paid numeric,
  entered_by text,
  last_payment_date date,
  last_payment_time text,
  receipt_data text,
  receipt_name text,
  created_at timestamptz default now()
);

-- Sale entries (Daily Entry → Sale tab)
create table if not exists public.qc_sale_entries (
  id uuid primary key,
  quarry text,
  entry_date date,
  entry_time text,
  permit_no text,
  load_number int,
  mt text,
  vendor_name text,
  vehicle_name text,
  vehicle_no text,
  product text,
  wheel numeric,
  unit numeric,
  pay_mode text,
  pay_mode_other text,
  load_amount numeric,
  permit_amount numeric,
  vehicle_rent numeric,
  rent_adjusted numeric,
  total numeric,
  status text,             -- 'Paid' | 'Pending'
  amount_paid numeric,
  entered_by text,
  last_payment_date date,
  last_payment_time text,
  receipt_data text,
  receipt_name text,
  created_at timestamptz default now()
);

-- IP Security allow-list (global scope — quarry = 'GLOBAL')
create table if not exists public.qc_allowed_ips (
  id uuid primary key,
  quarry text,             -- always 'GLOBAL' for this table
  ip text,
  label text,
  type text,                -- 'default' | 'temp'
  added_by text,
  expires_at timestamptz,   -- only set for 'temp' entries
  created_at timestamptz default now()
);

-- ============================================================
-- ENABLE RLS on the original tables (see setup_all.sql for the
-- newer expenses/hitachi tables + column additions)
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
      'qc_allowed_ips'
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
