from pathlib import Path

ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")

checks = {
    "3D player rig parts": ["actor_rigs", '"head": head', '"left_leg": left_leg', '"right_leg": right_leg', '"left_arm": left_arm', '"right_arm": right_arm'],
    "running limb animation": ["var swing := sin(animation_clock * 12.5)", "left_leg.rotation.x", "right_leg.rotation.x", "left_arm.rotation.x", "right_arm.rotation.x"],
    "goalkeeper dive animation": ["keeper_dive_time", "keeper_dive_time[keeper.get_instance_id()] = 0.42", "target_tilt = -0.72 if actor.position.x < 0.0 else 0.72"],
    "goalkeeper shot anticipation": ["shot_approach", "ball.linear_velocity.z * 0.22", "keeper_speed := 3.4 + (0.8"],
    "speed-aware save reach": ["var incoming_speed := ball.linear_velocity.length()", "var save_radius := 1.45 + minf(0.35, incoming_speed * 0.035)", "incoming_speed * 0.12"],
    "previous tactics retained": ['team_tactic = "Balanced"', 'team_tactic = "Attacking"', 'team_tactic = "Defensive"', 'career["team_tactic"] = team_tactic'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE14_SOURCE_CHECKS_PASSED")
