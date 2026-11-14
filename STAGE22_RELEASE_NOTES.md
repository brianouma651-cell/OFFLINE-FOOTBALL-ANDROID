# Stage 22 — Coordinated attacking movement

## Added
- Forward players now make staggered runs into different attacking lanes rather than all advancing toward the same space.
- Midfielders move into short passing-support positions behind and beside the ball carrier.
- Wide defenders can make selective overlaps when the team is attacking down a flank; the far-side full-back remains more conservative.
- When possession is lost, the team shifts toward the ball and restores a compact defensive line.
- Existing Balanced, Attacking and Defensive team tactics influence run depth and defensive positioning.

## Verification
- Stage 13–22 Python source regression checks pass.
- ZIP archive integrity is checked after packaging.
- These checks inspect source structure and expected integration points. They do not replace opening the project in Godot, live match testing, Android export, or testing the APK on a phone.
