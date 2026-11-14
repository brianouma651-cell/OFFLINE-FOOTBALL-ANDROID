# Stage 16 — Match rules and set-piece restarts

## Added
- Ball-out detection for touchlines and goal lines after goal detection.
- Throw-ins when the ball crosses a touchline.
- Corner kicks and goal kicks based on which side last touched the ball.
- Last-touch tracking for the controlled team's shots/passes/tackles and selected opposition actions.
- Foul restart selection, including a penalty spot when a foul is awarded in the attacking penalty-area zone.
- Restart ball placement, velocity reset, short restart lock, match-event logging and clear HUD messages.
- The controlled player is moved beside home-team restart positions so the restart can be taken with the existing SHOOT control.
- Penalty shots use a dedicated goal target; taking a shot clears the pending restart.

## Validation
- `python tests_stage13.py` — passed.
- `python tests_stage14.py` — passed.
- `python tests_stage15.py` — passed.
- `python tests_stage16.py` — passed.
- ZIP integrity and SHA-256 are checked in the release process.
- Godot editor/runtime validation, Android export and physical-device play testing remain pending. This is a source package, not an APK.

## Gameplay scope note
This stage adds simplified restart logic suitable for the current prototype. It does not yet implement a complete referee simulation, offside, advantage, cards, goalkeeper/defender last-touch arbitration for every physics collision, or fully automated opponent set-piece execution.
