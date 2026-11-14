# Stage 18 — Match reporting and league records

## Additions
- Expanded full-time match statistics with shots on target and goalkeeper saves.
- Added a shot-on-target estimate based on the projected shot path toward the goal mouth. This is an approximation and needs tuning during Godot runtime testing.
- Goalkeeper interventions are recorded in match events and counted as saves.
- Added a full match commentary screen showing the timestamped event log.
- Expanded league records to track played, won, drawn, lost, goals for, goals against and points.
- League standings sort by points and then goal difference.
- League records are persisted in the local career JSON save. Existing saves without this field are migrated lazily as teams are displayed/updated.
- Season rollover resets the league records along with the existing points table.

## Verification
Run `python tests_stage13.py`, `python tests_stage14.py`, `python tests_stage15.py`, `python tests_stage16.py`, `python tests_stage17.py`, and `python tests_stage18.py` from this directory.

These are source-level regression checks only. Godot 4 parsing/runtime, match simulation, Android export and physical-device testing remain pending.
