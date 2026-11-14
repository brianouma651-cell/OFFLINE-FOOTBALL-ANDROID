from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "league is a six-round double round robin": [
        'var schedule := ["Red City", "Coastal Rovers", "Highland FC", "Highland FC", "Coastal Rovers", "Red City"]',
        "func _fixture_home_for_club(index: int) -> bool:",
        "return posmod(index, 6) < 3",
    ],
    "home and away fixture labels are correct": [
        "func _fixture_description(index: int) -> String:",
        'return "%s vs %s" % [club_name, opponent_name]',
        'return "%s vs %s" % [opponent_name, club_name]',
        "current_fixture_home = _fixture_home_for_club(fixture_index) if is_career else true",
    ],
    "match results are recorded from the correct venue perspective": [
        'var fixture_home_name := club_name if current_fixture_home else current_opponent_name',
        'var fixture_away_name := current_opponent_name if current_fixture_home else club_name',
        'var fixture_home_score := score_home if current_fixture_home else score_away',
        'var fixture_away_score := score_away if current_fixture_home else score_home',
        '"club_home": current_fixture_home',
    ],
    "the remaining league fixture is simulated and counted": [
        "func _simulate_other_league_fixture(round_index: int) -> Dictionary:",
        'var remaining_fixtures := [',
        'var home_goals := randi_range(0, 3)',
        '_update_league_record(home_name, home_goals, away_goals)',
        '"other_fixture": other_fixture',
        'Other match: %s vs %s',
    ],
    "season advances after six completed league matches": [
        "if fixture_index >= 6:",
        "career.season = int(career.season) + 1",
        "fixture_index = 0",
        'for index in range(6):',
    ],
    "existing match and save systems remain integrated": [
        "func _finish_match(is_career: bool) -> void:",
        "_update_league_record(str(career.get(\"club\", \"Nairobi United\")), score_home, score_away)",
        "_update_league_record(current_opponent_name, score_away, score_home)",
        "func _save_career() -> void:",
        'career["fixture_results"] = fixture_results',
    ],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE24_SOURCE_CHECKS_PASSED")
