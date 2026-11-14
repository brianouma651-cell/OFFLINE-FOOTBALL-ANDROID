from pathlib import Path

ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")

required = {
    "three tactic states": ['team_tactic = "Balanced"', 'team_tactic = "Attacking"', 'team_tactic = "Defensive"'],
    "career UI tactic control": ['CHANGE TEAM TACTIC', 'Tactic: %s'],
    "persistent tactic save/load": ['career["team_tactic"] = team_tactic', 'career.get("team_tactic", "Balanced")'],
    "attacking and defensive support": ['run_distance = 5.2', 'run_distance = 1.4', 'var line := -7.0 if team_tactic != "Defensive" else -9.5'],
    "contextual opposition decisions": ['Opposition shot', 'Opposition builds an attack', 'carry_direction'],
}

for label, fragments in required.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: missing {missing}")
    print(f"PASS: {label}")

print("STAGE13_SOURCE_CHECKS_PASSED")
