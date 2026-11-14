# Stage 26 — Season history and champions archive

## Added
- Completed league seasons now archive the final full table before the next season begins.
- Each archive entry records the season number, champion, runner-up, and every club's final played/win/draw/loss, goals-for/goals-against and points totals.
- The archive uses the same deterministic ranking sequence as the live league table: points, goal difference, goals scored, wins, then club name.
- Season history is stored in the existing local career save and remains available after restarting the game.
- The fixtures/results screen displays the five most recent season honours; the archive retains up to 20 seasons.
- Starting a new career clears the previous career's season archive.

## Verification
- Run `python tests_stage13.py` through `python tests_stage26.py`.
- All checks are source-level regression checks. Godot 4 parsing/runtime, Android export and physical-device testing remain outstanding.
