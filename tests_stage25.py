from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "recent form stored in league records": ['"form": []', 'var form: Array = record.get("form", [])', 'record["form"] = form'],
    "form records wins draws and losses": ['var result_code := "D"', 'result_code = "W"', 'result_code = "L"'],
    "recent form limited to five results": ['while form.size() > 5:', 'form.pop_front()'],
    "complete league tie-break sequence": ['if pa != pb:', 'if ga != gb:', 'gfa > gfb', 'wa > wb', 'return str(a) < str(b)'],
    "expanded standings include goals and form": ['GF GA GD PTS', 'Recent form:', 'Ranking: Points → Goal difference → Goals scored → Wins → Club name'],
    "existing persistence and season flow retained": ['career["league_records"] = league_records', 'func _finish_match(is_career: bool)', 'if fixture_index >= 6:'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE25_SOURCE_CHECKS_PASSED")
