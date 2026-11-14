# Stage 17 — Offside and referee discipline

## Additions

- Checks the selected home pass receiver's position when a pass is played against the second-last opposition defender and the ball position.
- Tracks an offside-positioned receiver and awards an opposition indirect free kick if that receiver becomes involved by reaching the ball.
- Adds an opponent indirect-free-kick restart path.
- Adds a simple disciplinary model for late challenges: first detected late challenge records a yellow card; a second records a second-yellow dismissal.
- A dismissed controlled player receives a movement-speed penalty for the remainder of the match.
- Resets offside and disciplinary state at the start of each match.

## Limitations

This is an early gameplay simulation, not a complete Laws of the Game implementation. Offside is currently evaluated for home-team passes only, uses the simplified X-axis attacking direction, and detects involvement when the flagged receiver approaches the ball. The foul/card model only books the controlled home player for the existing probabilistic late-challenge event. Referee animations, assistant referees, advantage, direct/indirect restart distinction beyond offside, and full player dismissal/substitution rules remain future work.

## Verification

Run `python tests_stage13.py`, `python tests_stage14.py`, `python tests_stage15.py`, `python tests_stage16.py`, and `python tests_stage17.py` from this project folder. These are source-level regression checks, not Godot runtime tests. Godot parsing, gameplay, Android export, and physical-device testing remain pending.
