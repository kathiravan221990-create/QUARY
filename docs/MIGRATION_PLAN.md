# Quarry migration plan

Goal: move Quarry out of the shared free account to a Supabase account under a different email, so the main account keeps its two active projects (ERP database and Classic Pack Management / NEXUS) without Quarry being paused.

## What was found in the backup (2026-11-21)
Postgres 17, `public` schema, 12 tables. Row counts at backup time:

| Table | Rows |
|---|---|
| qc_allowed_ips | 5 |
| qc_cash_balance_daily | 7 |
| qc_expenses | 6 |
| qc_hitachi_entries | 0 |
| qc_landlord_entries | 3 (table no longer written by the app; migration 3 replaced it with rate settings in `qc_rate_matrix`) |
| qc_permits | 32 |
| qc_purchase_entries | 30 |
| qc_rate_matrix | 5 |
| qc_sale_entries | 0 |
| qc_sale_master | 1 |
| qc_transports | 1 |
| qc_vehicles | 1 |

Storage: no buckets and no objects. Nothing to copy there. Receipts, if any, are stored as text in `receipt_data` columns.
The data set is tiny, so the move is quick and low risk.

## Security finding
Every `qc_` table has an RLS policy `allow_all_anon` (`USING (true) WITH CHECK (true)` for `anon` and `authenticated`). Access control exists only in the app's own Employee/Owner login screen. Anyone who has the project URL and the publishable key (both are inside the HTML file) can read and write all quarry data directly through the API. Decide before or during the move whether to tighten this (for example Supabase Auth or a server-checked login).

## Login
The app's own login screen says the Owner and Employee passwords are set at build time, so some form of credential is inside the HTML file. Treat `app/QUARRY_CONSOLE.html` as sensitive: keep this repo private, and change the passwords when the app is rebuilt for the new project.

## Done (2026-11-21)
Steps 1-6 below were completed on the new project QUARY LEDGER. Extra finding: a new project does not grant table privileges to the public key, so `db/quarry_grants.sql` must be run after the schema. `qc_landlord_entries` was created with RLS enabled and no policy (the app does not use it).
Still open: step 7 (delete the old project after a few weeks), hosting, and the security tightening above.

## Steps
1. **Owner decision:** which email owns the new account. Prefer a long-term company-controlled email, with a second owner added.
2. Create the new Supabase project (free plan) under that account.
3. Run `db/quarry_public_schema.sql` in the new project's SQL editor.
4. Import data from the backup into the 12 tables (CSV import or `COPY`). Keep the original ids so references stay intact.
5. Copy `app/QUARRY_CONSOLE.html`, replace the Supabase URL and publishable key with the new project's, and host it as before.
6. Test live entries: purchase, sale, expense, permit, cash balance. Compare row counts with the table above.
7. Keep the old paused project and the backup file until the new one has run for a few weeks, then delete the old project.

## Later
- Konthamur Quary: add as another `quarry` value in the same tables (every table has a `quarry` column).
