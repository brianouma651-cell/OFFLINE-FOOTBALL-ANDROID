from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "season archive state exists": ["var season_history: Array = []"],
    "final table uses the established tie-break order": ["func _league_ranking_names() -> Array:", "return pa > pb", "return ga > gb", "return gfa > gfb", "return wa > wb", "return str(a) < str(b)"],
    "completed seasons archive full final standings": ["func _archive_completed_season() -> void:", '"champion": str(ordered[0])', '"runner_up": str(ordered[1])', '"table": final_table'],
    "archive is bounded and occurs before season reset": ["while season_history.size() > 20:", "_archive_completed_season()", 'career.season = int(career.season) + 1'],
    "season history persists across saves": ['career["season_history"] = season_history', 'season_history = career.get("season_history", [])'],
    "fixtures screen displays completed season honours": ['"SEASON HONOURS"', '"No completed seasons yet."', 'history.get("champion", "")'],
    "new career clears season history": ["season_history = []"],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE26_SOURCE_CHECKS_PASSED")
