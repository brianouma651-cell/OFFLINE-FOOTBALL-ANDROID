# Stage 25 — League form and full tie-break ranking

## Added
- League records now retain each club's five most recent results as W/D/L form.
- Form is updated for both played and simulated fixtures through the shared league-record updater.
- League ranking now uses a complete deterministic tie-break sequence: points, goal difference, goals scored, wins, then club name.
- Standings display goals for, goals against, goal difference, points and recent form.
- The existing local career save already persists league records, so form is retained automatically; older saves safely begin with an empty form history.

## Verification
- Run `python tests_stage13.py` through `python tests_stage25.py`.
- These are source regression checks. Godot 4 runtime, match simulation, Android export and physical-device testing remain required.
