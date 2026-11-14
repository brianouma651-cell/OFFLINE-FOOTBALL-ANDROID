# Stage 14 — Player animation and goalkeeper reactions

## Added
- Expanded player visuals into a lightweight 3D rig with head, torso, two legs and two arms.
- Running movement now animates alternating leg and arm swings with a subtle body bounce.
- Goalkeeper saves trigger a short dive/lean pose and arm extension.
- Goalkeepers anticipate the lateral direction of incoming shots and move faster when reacting to a fast threatening ball.
- Save reach and clearance strength scale modestly with incoming ball speed.
- Existing career save structure and Stage 13 team tactics are retained.

## Validation
- Stage 13 and Stage 14 source regression tests are included.
- ZIP integrity and SHA-256 are verified at packaging.
- Godot executable is not available in this packaging environment; engine parsing, runtime animation, Android export and physical-device testing remain pending.
- This package is Godot source, not an APK.
