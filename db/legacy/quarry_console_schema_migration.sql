-- ============================================================
-- QUARRY CONSOLE — schema additions for the new Input/Inventory/
-- Landlord features. Purely additive: nothing existing is
-- altered, dropped, or renamed. Safe to run more than once.
-- ============================================================

-- 1. Permits: bought by MT, and track which transport claimed one
ALTER TABLE qc_permits
  ADD COLUMN IF NOT EXISTS mt text,
  ADD COLUMN IF NOT EXISTS claimed_by_transport text;

-- 2. Vehicles: each vehicle now carries its own Vehicle No
ALTER TABLE qc_vehicles
  ADD COLUMN IF NOT EXISTS vehicle_no text;

-- 3. Sale (purchase_entries) and Direct Sale (sale_entries): who a UPI
--    payment was made to (Yashvanth / Appa / Amma / free-text other)
ALTER TABLE qc_purchase_entries
  ADD COLUMN IF NOT EXISTS upi_paid_to text;

ALTER TABLE qc_sale_entries
  ADD COLUMN IF NOT EXISTS upi_paid_to text;

-- 4. New table: Landlord payments by wheel type (6W/10W/12W), entered
--    manually, calculated separately from Sale/Direct Sale earnings.
CREATE TABLE IF NOT EXISTS qc_landlord_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quarry text NOT NULL,
  entry_date date NOT NULL,
  wheel text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- One amount per wheel type per day, per quarry — re-saving the same
-- day just updates it rather than creating duplicates (matches how the
-- app's Landlord tab behaves: it looks up an existing row for that
-- date+wheel before deciding to insert vs. update).
CREATE UNIQUE INDEX IF NOT EXISTS qc_landlord_entries_date_wheel_quarry
  ON qc_landlord_entries (quarry, entry_date, wheel);

-- If you use Row Level Security on your other qc_ tables, mirror the
-- same policy here so this table is readable/writable the same way.
-- Uncomment and adjust to match whatever policy your existing tables use:
-- ALTER TABLE qc_landlord_entries ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "quarry console access" ON qc_landlord_entries
--   FOR ALL USING (true) WITH CHECK (true);
