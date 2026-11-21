-- Table privileges the app needs on a NEW Supabase project (run after quarry_public_schema.sql).
-- New projects do not grant these automatically. Same access the original project had
-- (see the security note in docs/MIGRATION_PLAN.md). qc_landlord_entries is intentionally
-- left out: the app no longer uses it, and it has RLS enabled with no policy.
ALTER TABLE public.qc_landlord_entries ENABLE ROW LEVEL SECURITY;
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON
  public.qc_allowed_ips, public.qc_cash_balance_daily, public.qc_expenses, public.qc_hitachi_entries,
  public.qc_permits, public.qc_purchase_entries, public.qc_rate_matrix, public.qc_sale_entries,
  public.qc_sale_master, public.qc_transports, public.qc_vehicles
TO anon, authenticated;
