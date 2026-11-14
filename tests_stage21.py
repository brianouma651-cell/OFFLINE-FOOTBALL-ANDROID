from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "opposition tactical roles": ["func _opponent_tactical_target", "var tactical_target := _opponent_tactical_target(i, press_index)", "lane_z = -9.0", "lane_z = 9.0"],
    "goalkeeper trajectory anticipation": ["func _goalkeeper_anticipation_target", "var projected_z := ball.global_position.z + ball.linear_velocity.z * time_to_line", "var keeper_target := _goalkeeper_anticipation_target(defending_left, ball_is_threatening, shot_approach, anticipation)"],
    "player performance rating": ["func _calculate_player_performance_rating", "last_player_rating = _calculate_player_performance_rating()", "Controlled player: %.1f / 10"],
    "team performance rating": ["func _calculate_team_performance_rating", "last_team_rating = _calculate_team_performance_rating()", "Team: %.1f / 10"],
    "previous match and career systems retained": ["func _process_squad_after_match()", "func _show_match_commentary()", "func _update_league_record", "func _train_team()", "func _player_available(member: Dictionary) -> bool"],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE21_SOURCE_CHECKS_PASSED")
