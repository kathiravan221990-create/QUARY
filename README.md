# QUARY - Quarry Console

Live-entry quarry tracking tool for Sugumaran Quary (Konthamur Quary planned later).
Single-file HTML app backed by Supabase.

## Contents
| Path | What it is |
|---|---|
| `app/QUARRY_CONSOLE.html` | Latest app version (copy of `QUARRY_CONSOLE_ELITE(12).html`) |
| `db/quarry_public_schema.sql` | Structure-only schema of the 12 `qc_` tables, extracted from the project backup. Source of truth for rebuilding |
| `db/quarry_grants.sql` | Table privileges a new project needs so the app can read and write (run after the schema) |
| `db/legacy/` | The original hand-written SQL files (original schema, setup_all, three migrations), kept for history |
| `docs/MIGRATION_PLAN.md` | Plan to move Quarry to a Supabase account under another email |

## Status (2026-11-21)
- **Moved.** Quarry now runs on the new Supabase project **QUARY LEDGER** (ref `uukyegryihamwtmfaqbt`, ap-southeast-1) in the `kathirkayal22@gmail.com` account. `app/QUARRY_CONSOLE.html` points at it.
- All 91 rows were loaded from the backup and checked: counts per table match, and the purchase total (91,500) matches.
- The old `QUARRY` project (ref `eldapxblyeiejhpwghtu`) is still paused and untouched. Keep it, and the downloaded backup, for a few weeks before deleting.
- The old version of the app (pointing at the old project) is in the git history of `app/QUARRY_CONSOLE.html`.
- Not yet done: hosting link, and tightening database access (see `docs/MIGRATION_PLAN.md`).

## Rules for this repo
- No data, no backups, no passwords, no service-role keys.
- The app contains a Supabase **publishable** key by design; it is replaced during migration.


## Status (2026-11-21)
- Database: QUARY LEDGER (Supabase). All `qc_` tables are locked by row-level security; the public key cannot read anything without a login.
- Login: Supabase Auth with Username + Role (auto-filled) + Password. Roles: Administrator (super), Owner, Employee. Administrator manages users from the *Users & Roles* tile (uses the `qc-admin` edge function in `supabase/functions/qc-admin`).
- Public sign-ups are disabled. No passwords or service keys are stored in this repository.
- Live app: https://kathiravan221990-create.github.io/QUARY/
