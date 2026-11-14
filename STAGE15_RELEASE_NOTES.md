# Stage 15 — Ball control and attacking decisions

## Added
- Close-control ball handling uses small physics impulses instead of snapping the ball to the player.
- Stationary close control reduces horizontal ball speed to make trapping more useful.
- Shooting now aims at a goal target with a small lateral adjustment based on ball position.
- Shot power is slightly moderated when shooting from very close range.
- Passing evaluates teammate separation, forward movement and available lane space rather than always selecting the nearest teammate.
- Passes lead a moving teammate slightly to encourage receiving the ball in stride.

## Validation
- Stage 13, 14 and 15 source regression tests are included.
- ZIP integrity and SHA-256 are verified.
- Godot runtime, physics feel, Android export and physical-device play testing remain pending because Godot is not installed in the packaging environment.
- This is a source package, not an APK.
