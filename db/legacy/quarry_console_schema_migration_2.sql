-- ============================================================
-- QUARRY CONSOLE — schema addition for OLD GRAVEL / OLD RED SOIL
-- products. Purely additive, safe to run more than once.
-- ============================================================

ALTER TABLE qc_rate_matrix
  ADD COLUMN IF NOT EXISTS old_gravel_amount numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS old_redsoil_amount numeric DEFAULT 0;
