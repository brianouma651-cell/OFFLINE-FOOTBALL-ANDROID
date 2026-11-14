from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "persistent condition fields": ['"fitness"', '"injury_matches"', '"suspension_matches"', '"yellow_cards_season"'],
    "legacy roster migration": ['func _ensure_player_condition', 'member.get("fitness", 100)', 'member.get("injury_matches", 0)'],
    "availability checks": ['func _player_available', 'injury_matches', 'suspension_matches'],
    "match-week recovery and fatigue": ['func _process_squad_after_match', 'fitness", 100)) - 12', 'fitness", 100)) + 18'],
    "low-fitness injury event": ['randf() < 0.12', 'randi_range(1, 2)', 'picked up an injury'],
    "injured and suspended players excluded from lineup": ['and _player_available(member)', 'eligible reserves fill vacancies'],
    "unavailable substitutes excluded": ['and _player_available(candidate)'],
    "fitness training": ['member["fitness"] = mini(100, int(member.get("fitness", 100)) + 8)'],
    "squad condition display": ['Squad condition:', 'Fitness %d%%', 'Injured: %d / Suspended: %d'],
    "career fixture advances recovery": ['_process_squad_after_match()'],
    "previous match and career features retained": ['func _show_match_commentary()', 'func _update_league_record', 'func _make_substitution()', 'func _show_transfer_market'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE19_SOURCE_CHECKS_PASSED")
