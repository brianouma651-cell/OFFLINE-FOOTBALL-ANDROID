# Offline Football Android — Stage 26

A continuing Godot 4 project for a fully offline 3D football game with local career and club management. No server, account, hosting, or online connection is required.

## Stage 12 additions

- Four selectable club presets: Nairobi United, Mombasa Mariners, Kisumu Lakeside, and Eldoret Athletic.
- Custom club naming remains available.
- Four home kit palettes: Royal Blue, Ocean Teal, Forest Green, and Crimson.
- Opponent kit colours vary by opponent club (Red City, Coastal Rovers, Highland FC).
- Home kit selection is stored in the local career save.
- Match camera zoom-in and zoom-out controls, clamped to a safe range.
- Existing exhibition and career matches, squad/transfer management, fixtures, match controls, pause menu, and local save are retained.

## Open the project

1. Install Godot 4.x on a computer.
2. Extract the ZIP archive.
3. In Godot Project Manager, choose **Import** and select `project.godot` inside `OFFLINE_FOOTBALL_GODOT`.
4. Run the project with F6/F5 or the editor's Run button.
5. For Android, install the matching Godot Android export templates and Android build dependencies, then follow `ANDROID_BUILD_CHECKLIST.txt`.

## Controls

- On-screen directional buttons: move the selected player.
- SHOOT, PASS, TACKLE, SWITCH, SUBSTITUTE, FREE KICK: match actions.
- ZOOM + / ZOOM -: adjust the match camera.
- PAUSE MATCH: pause, resume, restart, or end the match.

## Important validation status

This is a source package, not an APK. The archive can be checked for ZIP integrity, but Godot is not installed in the packaging environment. Therefore GDScript parsing, runtime gameplay, Android export, and physical-device installation have **not** been verified. Treat the project as an evolving prototype until those checks are completed.

## Stage 14 update
Stage 14 adds articulated player visuals, running limb animation, goalkeeper dive poses, shot anticipation and speed-aware saves. See `STAGE14_RELEASE_NOTES.md` and run `python tests_stage13.py` plus `python tests_stage14.py` for source-level regression checks. Godot runtime and Android export still require validation in Godot 4.

## Stage 15 update
Stage 15 improves close-control ball physics, goal-directed shooting and space-aware passing. Run `python tests_stage13.py`, `python tests_stage14.py` and `python tests_stage15.py` for source-level checks.

## Stage 16 update
Stage 16 adds simplified touchline/goal-line decisions, throw-ins, corners, goal kicks, foul/penalty restart placement and last-touch tracking. Run all four source checks: `python tests_stage13.py`, `python tests_stage14.py`, `python tests_stage15.py`, and `python tests_stage16.py`. These are source regression checks only; Godot runtime and Android export are still unverified.

## Stage 17 update
Stage 17 adds a first-pass offside check for home-team passes, an opposition indirect free kick when an offside receiver becomes involved, and a simple yellow/second-yellow dismissal model for detected late challenges. See `STAGE17_RELEASE_NOTES.md`. Run all five stage test scripts. These checks inspect source features only; they do not replace Godot 4 runtime testing or Android device validation.

## Stage 18 update
Stage 18 expands match reports with estimated shots on target and goalkeeper saves, adds a full timestamped commentary screen, and upgrades league standings to include played, wins, draws, losses, goals for/against, goal difference and points. League records are saved locally and older career saves remain supported. Run `python tests_stage18.py` alongside all earlier stage test scripts. The shot-on-target calculation is an approximation pending in-engine gameplay validation.

## Stage 20 update
Stage 20 adds selectable specialist training plans: Balanced, Fitness, Attacking, Passing, Defending, and Goalkeeping. Specialist sessions improve the selected team attribute, while Fitness sessions focus on restoring squad condition. The selected focus is saved locally, defaults safely to Balanced for older career saves, and is visible in Club Management. Run `python tests_stage20.py` together with all previous stage tests. These are source-level checks only; Godot runtime and Android export remain unverified.

## Stage 21 update
Stage 21 improves opposition defensive support positioning, adds velocity-based goalkeeper shot anticipation, and displays controlled-player and team performance ratings at full time. Run `python tests_stage21.py` alongside all previous stage checks. These are source-level checks only; Godot runtime and Android export remain unverified.

## Stage 22 update
Stage 22 improves coordinated team movement: forwards make staggered runs, midfielders offer passing support, wide defenders selectively overlap, and the team recovers into a compact shape after losing possession. See `STAGE22_RELEASE_NOTES.md`.

## Stage 23 update
Stage 23 gives the opposition context-aware attacking choices: it evaluates goal distance and defensive pressure before shooting, searches for a forward runner in space before passing, and otherwise carries the ball into space. See `STAGE23_RELEASE_NOTES.md` and run `python tests_stage23.py` together with all earlier stage scripts.


## Stage 24 update — League fixtures and matchdays
Stage 24 completes the four-club league schedule as six rounds with home and away legs against each rival. Each matchday also simulates the other league fixture locally and updates both clubs' league records. Fixture results now display the correct home/away teams and score order. See `STAGE24_RELEASE_NOTES.md`; run `python tests_stage24.py` together with `python tests_stage13.py` through `python tests_stage23.py`. Source-level tests do not replace Godot runtime, Android export or phone testing.


## Stage 25 update — League form and tie-break rules
Stage 25 adds each club's last-five W/D/L form, a deterministic points/goal-difference/goals-scored/wins/name tie-break sequence, and a more complete standings display. League form is saved as part of the existing league records and remains backward-compatible with older career saves. Run `python tests_stage25.py` together with all earlier stage checks. These source checks do not replace Godot runtime or Android testing.


## Stage 26 update — Season history and champions archive
Completed seasons now preserve the final league table, champion and runner-up in the local career save. The fixtures screen shows recent season honours, with up to 20 seasons retained. See `STAGE26_RELEASE_NOTES.md` and run `tests_stage26.py` together with all earlier stage checks. These are source-level checks only; Godot runtime and Android export remain unverified.
