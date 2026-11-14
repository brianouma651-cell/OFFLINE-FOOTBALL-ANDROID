from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "restart state reset per match": ["var restart_type := \"None\"", "restart_type = \"None\"", "restart_for_home = true"],
    "foul and penalty decisions": ["func _award_free_kick(reason: String)", 'restart_type = "Penalty"', 'restart_type = "Free kick"', 'restart_position = Vector3(FIELD_LENGTH / 2.0 - 5.0'],
    "throw-in and goal-line restart rules": ["func _handle_ball_out()", 'restart_type = "Throw-in"', 'restart_type = "Corner"', 'restart_type = "Goal kick"', "restart_for_home = not last_touch_home"],
    "restart ball placement and stoppage": ["ball.linear_velocity = Vector3.ZERO", "ball.angular_velocity = Vector3.ZERO", "ball_reset_lock = 0.6", "player.position = restart_position + Vector3(-1.5, 0.0, 0.0)", 'restart_type + \" awarded\"'],
    "penalty shot and possession tracking": ['if restart_type == "Penalty"', "last_touch_home = true", "last_touch_home = false", 'restart_type = "None"'],
    "previous stages retained": ["actor_rigs", "keeper_dive_time", "dribble_push", "best_score := -INF", 'team_tactic = "Balanced"'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE16_SOURCE_CHECKS_PASSED")
