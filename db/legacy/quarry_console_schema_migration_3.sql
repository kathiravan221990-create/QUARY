-- ============================================================
-- QUARRY CONSOLE — schema addition for the new rate-based
-- Landlord Payment (replaces the old daily-entry approach).
-- Purely additive, safe to run more than once.
-- ============================================================

ALTER TABLE qc_rate_matrix
  ADD COLUMN IF NOT EXISTS is_landlord_setting boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS landlord_rate_6w numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS landlord_rate_10w numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS landlord_rate_12w numeric DEFAULT 0;

-- Note: the earlier qc_landlord_entries table (daily amounts) is no
-- longer written to or read by the app — it's left in place untouched
-- in case you want to keep its historical rows, but nothing new goes
-- into it. Nothing to delete unless you want to clean it up yourself.
