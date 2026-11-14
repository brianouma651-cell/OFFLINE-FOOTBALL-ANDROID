# Stage 24 — Complete six-round league fixtures and matchday simulation

## Added
- Replaced the repeating ten-opponent list with a six-round double round-robin schedule for the four-club league.
- Each of the three rival clubs is played once at home and once away.
- Career fixtures now display the correct home and away order.
- Match results are written from the actual venue perspective, including the correct home/away score order.
- The second fixture in every league round is simulated locally, so the other two clubs also accumulate played, win/draw/loss, goals and points records.
- Fixtures & Results displays both the user's match and the other match in each completed round.
- The season advances after all six user fixtures are completed and the next season's league records are reset.
- Existing save/load fields remain in use; older career saves receive the new home/away behaviour from their existing fixture index.

## Verification
- Stage 13–24 source regression scripts pass.
- ZIP archive integrity and SHA-256 checksum are verified.
- Godot 4 parsing/runtime, live match play, Android export and physical-device installation have not been performed in this environment. These remain required acceptance tests.
