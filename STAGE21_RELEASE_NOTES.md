# Stage 21 — Match intelligence and performance ratings

## Additions
- Opposition outfield players now use more contextual defensive support positions: one player presses the ball while teammates cover central and wide passing lanes.
- Goalkeepers estimate the ball's likely lateral position at the goal line using its current velocity, improving anticipation of shots that are travelling across the goalmouth.
- Full-time reports now show a controlled-player performance rating and a team performance rating, both on a 1.0–10.0 scale.
- Player ratings consider shots on target, passes, tackles, and the match result. Team ratings consider the result, estimated possession, and passing activity.
- All features operate locally and offline; earlier career, training, match, and squad systems remain in the cumulative project.

## Validation
- `tests_stage13.py` through `tests_stage21.py` are source-level regression checks.
- These checks do not replace Godot 4 parsing, live gameplay, Android export, or physical-device testing.
- This remains a cumulative Godot source package, not an installable APK.
