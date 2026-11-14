# Stage 19 — Player condition and availability

Stage 19 extends the Stage 18 project with persistent squad-condition data.

## Included
- Per-player fitness, injury duration, suspension duration, and season yellow-card counter fields, with defaults added when older career saves load.
- Players who are injured or suspended are omitted from the starting lineup; eligible reserves fill available places.
- Match substitutions now ignore unavailable reserves.
- After each career fixture, players who featured lose fitness while unused squad members recover. Injury and suspension counters advance by one fixture.
- Very low-fitness players have a small chance of a one- or two-fixture injury after playing.
- Squad training restores some fitness as well as retaining its existing rating/attribute improvements.
- Squad screens show fitness and availability; career dashboard shows unavailable and low-fitness counts.

## Scope and limitations
- Injury is a simplified management simulation, not a collision/medical simulation.
- The suspension field and migration support are present, but this stage does not yet connect individual referee card events to named players or automatically issue suspensions.
- Recovery advances only after career matches, not exhibition matches or real-world time.
- Godot runtime parsing, visual testing, Android export, and phone installation remain unverified because no Godot executable is available in the build environment.
