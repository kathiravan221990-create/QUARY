-- QUARRY CONSOLE - public schema (structure only, no data)
-- Extracted from the paused QUARRY project's database backup (project ref eldapxblyeiejhpwghtu).
-- Run on a fresh Supabase project to recreate tables, keys, indexes and RLS policies.
-- NOTE: every policy below is allow-all for the anon role (see docs/MIGRATION_PLAN.md, Security).

CREATE TABLE public.qc_allowed_ips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text,
    ip text NOT NULL,
    label text,
    type text NOT NULL,
    added_by text,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_cash_balance_daily (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    entry_date date NOT NULL,
    opening_balance numeric DEFAULT 0 NOT NULL,
    closing_balance numeric DEFAULT 0 NOT NULL,
    is_manual boolean DEFAULT false NOT NULL,
    entered_by text,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_expenses (
    id uuid NOT NULL,
    quarry text,
    entry_date date,
    entry_time text,
    expense_type text,
    custom_type text,
    amount numeric,
    notes text,
    entered_by text,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_hitachi_entries (
    id uuid NOT NULL,
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
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_landlord_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    entry_date date NOT NULL,
    wheel text NOT NULL,
    amount numeric DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.qc_permits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    permit_no text NOT NULL,
    date_added date NOT NULL,
    load_count integer DEFAULT 0,
    status text DEFAULT 'active'::text,
    created_at timestamp with time zone DEFAULT now(),
    mt text,
    claimed_by_transport text
);

CREATE TABLE public.qc_purchase_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    entry_date date NOT NULL,
    entry_time text,
    permit_no text,
    load_number integer,
    mt numeric,
    transport_name text,
    vehicle_name text,
    vehicle_no text,
    product text,
    wheel numeric,
    unit numeric,
    pay_mode text,
    pay_mode_other text,
    permit_amount numeric DEFAULT 0,
    load_amount numeric DEFAULT 0,
    total numeric DEFAULT 0,
    status text DEFAULT 'Pending'::text,
    amount_paid numeric DEFAULT 0,
    entered_by text,
    created_at timestamp with time zone DEFAULT now(),
    last_payment_date date,
    last_payment_time text,
    receipt_data text,
    receipt_name text,
    cash_amount numeric,
    upi_amount numeric,
    last_payment_mode text,
    upi_paid_to text
);

CREATE TABLE public.qc_rate_matrix (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    wheel numeric,
    unit numeric,
    gravel_amount numeric DEFAULT 0,
    redsoil_amount numeric DEFAULT 0,
    is_permit_setting boolean DEFAULT false,
    permit_amount numeric DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    is_hitachi_rate boolean,
    hourly_rate numeric,
    old_gravel_amount numeric DEFAULT 0,
    old_redsoil_amount numeric DEFAULT 0,
    is_landlord_setting boolean DEFAULT false,
    landlord_rate_6w numeric DEFAULT 0,
    landlord_rate_10w numeric DEFAULT 0,
    landlord_rate_12w numeric DEFAULT 0
);

CREATE TABLE public.qc_sale_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    entry_date date NOT NULL,
    entry_time text,
    permit_no text,
    load_number integer,
    mt numeric,
    vendor_name text,
    vehicle_name text,
    vehicle_no text,
    product text,
    wheel numeric,
    unit numeric,
    pay_mode text,
    pay_mode_other text,
    permit_amount numeric DEFAULT 0,
    vehicle_rent numeric DEFAULT 0,
    rent_adjusted numeric DEFAULT 0,
    load_amount numeric DEFAULT 0,
    total numeric DEFAULT 0,
    status text DEFAULT 'Pending'::text,
    amount_paid numeric DEFAULT 0,
    entered_by text,
    created_at timestamp with time zone DEFAULT now(),
    last_payment_date date,
    last_payment_time text,
    receipt_data text,
    receipt_name text,
    cash_amount numeric,
    upi_amount numeric,
    last_payment_mode text,
    upi_paid_to text
);

CREATE TABLE public.qc_sale_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    order_name text,
    lorry_name text,
    rate numeric DEFAULT 0,
    rental numeric DEFAULT 0,
    combined_rate numeric DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_transports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.qc_vehicles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quarry text NOT NULL,
    transport_id uuid,
    vehicle_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    vehicle_no text
);

ALTER TABLE ONLY public.qc_allowed_ips
    ADD CONSTRAINT qc_allowed_ips_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_cash_balance_daily
    ADD CONSTRAINT qc_cash_balance_daily_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_cash_balance_daily
    ADD CONSTRAINT qc_cash_balance_daily_quarry_entry_date_key UNIQUE (quarry, entry_date);

ALTER TABLE ONLY public.qc_expenses
    ADD CONSTRAINT qc_expenses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_hitachi_entries
    ADD CONSTRAINT qc_hitachi_entries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_landlord_entries
    ADD CONSTRAINT qc_landlord_entries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_permits
    ADD CONSTRAINT qc_permits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_purchase_entries
    ADD CONSTRAINT qc_purchase_entries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_rate_matrix
    ADD CONSTRAINT qc_rate_matrix_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_sale_entries
    ADD CONSTRAINT qc_sale_entries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_sale_master
    ADD CONSTRAINT qc_sale_master_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_transports
    ADD CONSTRAINT qc_transports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.qc_vehicles
    ADD CONSTRAINT qc_vehicles_pkey PRIMARY KEY (id);

CREATE INDEX idx_qc_permits_quarry ON public.qc_permits USING btree (quarry, status);

CREATE INDEX idx_qc_purchase_date ON public.qc_purchase_entries USING btree (quarry, entry_date);

CREATE INDEX idx_qc_sale_date ON public.qc_sale_entries USING btree (quarry, entry_date);

CREATE UNIQUE INDEX qc_landlord_entries_date_wheel_quarry ON public.qc_landlord_entries USING btree (quarry, entry_date, wheel);

ALTER TABLE ONLY public.qc_vehicles
    ADD CONSTRAINT qc_vehicles_transport_id_fkey FOREIGN KEY (transport_id) REFERENCES public.qc_transports(id) ON DELETE CASCADE;

CREATE POLICY allow_all_anon ON public.qc_allowed_ips TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_expenses TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_hitachi_entries TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_permits TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_purchase_entries TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_rate_matrix TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_sale_entries TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_sale_master TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_transports TO authenticated, anon USING (true) WITH CHECK (true);

CREATE POLICY allow_all_anon ON public.qc_vehicles TO authenticated, anon USING (true) WITH CHECK (true);

ALTER TABLE public.qc_allowed_ips ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_cash_balance_daily ENABLE ROW LEVEL SECURITY;

CREATE POLICY qc_cash_balance_daily_allow_all ON public.qc_cash_balance_daily USING (true) WITH CHECK (true);

ALTER TABLE public.qc_expenses ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_hitachi_entries ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_permits ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_purchase_entries ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_rate_matrix ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_sale_entries ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_sale_master ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_transports ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.qc_vehicles ENABLE ROW LEVEL SECURITY;
