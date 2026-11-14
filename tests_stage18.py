from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "expanded match statistics": ['"shots_on_target"', '"saves"', 'func _show_result', 'Estimated possession'],
    "shot-on-target estimate": ['var projected_goal_z :=', 'match_stats.shots_on_target'],
    "goalkeeper saves recorded": ['match_stats.saves = int(match_stats.get("saves", 0)) + 1', 'Goalkeeper makes a save'],
    "full match commentary": ['func _show_match_commentary()', 'FULL MATCH COMMENTARY', 'BACK TO FULL-TIME REPORT'],
    "complete league records": ['var league_records: Dictionary = {}', 'func _update_league_record', '"played": 0', '"gf": 0', '"ga": 0'],
    "league ranking points then goal difference": ['ordered.sort_custom', 'if pa != pb:', 'if ga != gb:', 'gfa > gfb'],
    "league records update for both clubs": ['_update_league_record(str(career.get("club", "Nairobi United")), score_home, score_away)', '_update_league_record(current_opponent_name, score_away, score_home)'],
    "backward-compatible career persistence": ['career["league_records"] = league_records', 'league_records = career.get("league_records", {})'],
    "prior gameplay retained": ['func _check_offside()', 'func _make_substitution()', 'func _show_transfer_market', 'func _handle_ball_out()'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE18_SOURCE_CHECKS_PASSED")
