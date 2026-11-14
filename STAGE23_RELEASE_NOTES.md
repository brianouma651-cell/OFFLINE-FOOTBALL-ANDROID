# Stage 23 — Context-aware opposition attacking decisions

## Added
- Opposition ball carriers now choose among shooting, passing forward to a teammate, and carrying into space.
- Shot selection considers distance and angle to goal as well as nearby defensive pressure.
- Forward-pass selection evaluates opposition runners' forward progress and nearby space from home defenders.
- The opposition records distinct match events for shots, forward passes and carries.
- The existing difficulty factor continues to influence shot and pass power.

## Verification
- Stage 13–23 source regression scripts pass.
- ZIP archive integrity and SHA-256 checksum are verified after packaging.
- These are source-level checks only. Godot parsing/runtime, live gameplay, Android export and physical-device installation still require validation in Godot 4.
