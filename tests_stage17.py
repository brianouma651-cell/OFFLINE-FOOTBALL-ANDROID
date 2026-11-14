from pathlib import Path
ROOT = Path(__file__).parent
SCRIPT = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
checks = {
    "offside state and match reset": ["var pending_offside_actor_id := 0", "var offside_check_cooldown := 0.0", "pending_offside_actor_id = 0", "offside_check_cooldown = 0.0"],
    "offside position at pass moment": ["func _pass_ball()", "var opponent_line: Array[float] = []", "opponent_line.append(goalkeepers[1].global_position.x)", "receiver_x > second_last_defender_x"],
    "offside infringement and indirect restart": ["func _check_offside()", 'restart_type = "Indirect free kick"', '"Offside — opposition indirect free kick"', "restart_for_home = false"],
    "referee disciplinary decisions": ["var yellow_cards_home := 0", "var red_cards_home := 0", '"Yellow card — home player"', '"Second yellow — home player sent off"'],
    "dismissal affects player movement": ["var player_sent_off := false", "var dismissal_factor := 0.88 if player_sent_off else 1.0", "* dismissal_factor"],
    "opponent indirect free kick execution": ["opponent_restart_direction", 'status_label.text = "Opposition takes the indirect free kick."', "last_touch_home = false"],
    "previous stages retained": ["func _handle_ball_out()", 'restart_type = "Throw-in"', 'restart_type = "Corner"', "func _animate_actor", "dribble_push", "func _show_transfer_market"],
}
for label, fragments in checks.items():
    missing = [fragment for fragment in fragments if fragment not in SCRIPT]
    if missing:
        raise SystemExit(f"FAIL: {label}: {missing}")
    print(f"PASS: {label}")
print("STAGE17_SOURCE_CHECKS_PASSED")
