from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "close-control physics": ["var ball_distance := player.global_position.distance_to(ball.global_position)", "dribble_push := direction.normalized() * (0.34 if ball_distance < 0.9 else 0.46)", "ball.linear_velocity.x *= 0.91", "ball.linear_velocity.z *= 0.91"],
    "goal-directed shooting": ["var goal_target := Vector3(FIELD_LENGTH / 2.0 + 1.0, 1.0", "var shot_power := 7.5", "if ball.global_position.x > 9.0", "ball.apply_central_impulse(direction.normalized() * shot_power)"],
    "space-aware teammate selection": ["var best_score := -INF", "var forward_space := mate.global_position.x - player.global_position.x", "var lane_space := 1.0 - minf", "var lead_position := best_mate.global_position + best_mate.velocity * 0.32"],
    "previous stages retained": ["actor_rigs", "keeper_dive_time", 'team_tactic = "Balanced"', 'career["team_tactic"] = team_tactic'],
}
for label, fragments in checks.items():
    missing = [x for x in fragments if x not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE15_SOURCE_CHECKS_PASSED")
