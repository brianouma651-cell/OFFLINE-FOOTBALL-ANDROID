from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "training focus options": ['const TRAINING_FOCUSES := ["Balanced", "Fitness", "Attacking", "Passing", "Defending", "Goalkeeping"]'],
    "focus selection and cycling": ["func _cycle_training_focus()", "TRAINING_FOCUSES.find(training_focus)", "_cycle_training_focus)"],
    "specialist attribute development": ['trained_attribute = "shooting"', 'trained_attribute = "passing"', 'trained_attribute = "defending"', 'trained_attribute = "goalkeeping"'],
    "fitness-specific training": ['member["fitness"] = mini(100, int(member.get("fitness", 100)) + 20)'],
    "training focus saved": ['career["training_focus"] = training_focus'],
    "legacy save migration": ['career.get("training_focus", "Balanced")', 'if not TRAINING_FOCUSES.has(training_focus)'],
    "training focus shown in management": ['"Training focus: " + training_focus', '"TRAIN: %s  (- KSh 10,000)" % training_focus.to_upper()'],
    "reset defaults": ['training_focus = "Balanced"'],
    "earlier condition and match systems retained": ['func _process_squad_after_match()', 'func _show_match_commentary()', 'func _update_league_record', 'func _player_available'],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE20_SOURCE_CHECKS_PASSED")
