# Stage 13 — Tactical gameplay and opposition decisions

## Added
- Three persistent team tactics: Balanced, Attacking, and Defensive.
- Club Management now displays the active tactic and provides a cycle control.
- Attacking tactics push forwards and midfield support runs higher; defensive tactics hold midfield and defensive lines deeper.
- Opposition ball decisions are contextual: the nearest opponent carries forward, attempts a build-up pass in the attacking half, and shoots only when close to the home goal.
- Opposition attacking actions are recorded in the match event feed.
- The selected tactic is stored in the local career save and defaults safely to Balanced for older saves.

## Validation status
- Source-level regression checks and ZIP integrity are included in the Stage 13 handoff.
- Godot is not installed in the packaging environment. GDScript parsing, in-engine match behaviour, Android export, and physical-phone testing remain unverified.
- This is still a Godot source package, not an APK.
