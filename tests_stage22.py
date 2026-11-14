from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "coordinated teammate movement is active": [
        "func _teammate_tactical_target(roster_index: int, role: String, formation_target: Vector3) -> Vector3:",
        "var target := _teammate_tactical_target(roster_index, role, _formation_position(roster_index))",
    ],
    "forwards make staggered attacking runs": [
        'if role == "Forward":',
        "var desired_lane := clampf(ball_z * 0.58 + lane_offset, -8.0, 8.0)",
        "target.x = clampf(maxf(target.x + run_distance, ball_x + 3.0), -2.0, 14.5)",
    ],
    "midfielders offer passing support": [
        'elif role == "Midfielder":',
        "var support_depth := 3.8 if team_tactic != \"Attacking\" else 2.8",
        "target.x = clampf(ball_x - support_depth, -10.0, 8.0)",
    ],
    "wide defenders selectively overlap": [
        "var wide_fullback := roster_index == 0 or roster_index == 3",
        'team_tactic == "Attacking"',
        "target.z = clampf(ball_z * 1.12, -9.0, 9.0)",
    ],
    "team shape recovers when possession is lost": [
        "if not attacking:",
        "var compact_line := -7.0 if team_tactic != \"Defensive\" else -9.5",
        "target.z = lerpf(target.z, ball_z * 0.52 + target.z * 0.48, 0.28)",
    ],
    "no malformed escaped indentation remains": [
        "keeper_save_cooldown = 0.9",
    ],
    "previous stages remain integrated": [
        "func _calculate_player_performance_rating() -> float:",
        "func _goalkeeper_anticipation_target(",
        "func _process_squad_after_match()",
        "func _train_team()",
        "func _check_offside()",
    ],
}
if "\\t" in SCRIPT:
    raise SystemExit("FAIL: malformed literal backslash-t remains in GDScript source")
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE22_SOURCE_CHECKS_PASSED")
