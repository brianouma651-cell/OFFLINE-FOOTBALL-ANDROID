from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "opposition uses a dedicated decision function": [
        "func _opponent_attack_decision() -> void:",
        "_opponent_attack_decision()",
    ],
    "shot selection considers goal distance and pressure": [
        "var goal_distance := absf(ball.global_position.x + FIELD_LENGTH / 2.0)",
        "var nearest_pressure := player.global_position.distance_to(ball.global_position)",
        "var can_shoot := goal_distance < 11.0",
        '"Opposition shot"',
    ],
    "forward pass selection evaluates available runners": [
        "var best_runner: CharacterBody3D = null",
        "for runner in opponents:",
        "var lane_space := 1.0",
        "var pass_target := best_runner.global_position + Vector3(-1.0, 0.25, 0.0)",
        '"Opposition builds an attack — forward pass"',
    ],
    "fallback carries the ball into attacking space": [
        "var carry_direction := Vector3(-1.0, 0.035, clampf(-ball.global_position.z * 0.035, -0.3, 0.3)).normalized()",
        '"Opposition carries the ball"',
    ],
    "previous tactical and career systems remain integrated": [
        "func _teammate_tactical_target(",
        "func _goalkeeper_anticipation_target(",
        "func _check_offside()",
        "func _save_career()",
        "func _show_transfer_market()",
    ],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
if "\\t" in SCRIPT:
    raise SystemExit("FAIL: literal escaped tab sequence found")
print("STAGE23_SOURCE_CHECKS_PASSED")
