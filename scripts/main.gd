extends Node3D

const SAVE_PATH := "user://career_save.json"
const FIELD_LENGTH := 34.0
const FIELD_WIDTH := 22.0
const GOAL_HALF_WIDTH := 3.0
const GOAL_HEIGHT := 2.4
const PLAYER_SPEED := 6.0
const AI_SPEED := 2.7

var player: CharacterBody3D
var ball: RigidBody3D
var opponents: Array[CharacterBody3D] = []
var teammates: Array[CharacterBody3D] = []
var goalkeepers: Array[CharacterBody3D] = []
var match_camera: Camera3D
var tackle_cooldown := 0.0
var score_home := 0
var score_away := 0
var seconds_left := 300.0
var match_running := false
var career := {"club": "Nairobi United", "season": 1, "played": 0, "wins": 0, "points": 0, "cash": 250000}
var hud: Label
var status_label: Label
var screen_root: Control
var move_vector := Vector2.ZERO
var shoot_requested := false
var match_timer: Timer
var opponent_shot_cooldown := 0.0
var opponent_action_cooldown := 0.0
var current_match_is_career := false
var ball_reset_lock := 0.0
var formation_name := "4-3-3"
var team_tactic := "Balanced"
var training_focus := "Balanced"
const TRAINING_FOCUSES := ["Balanced", "Fitness", "Attacking", "Passing", "Defending", "Goalkeeping"]
var switch_cooldown := 0.0
var foul_count := 0
var yellow_cards_home := 0
var red_cards_home := 0
var player_sent_off := false
var pending_offside_actor_id := 0
var pending_offside_position := Vector3.ZERO
var offside_check_cooldown := 0.0
var last_touch_home := true
var restart_type := "None"
var restart_position := Vector3.ZERO
var restart_for_home := true
var match_stats := {"shots": 0, "passes": 0, "tackles": 0, "possession_ticks": 0, "opponent_ticks": 0}
var substitutions_used := 0
var squad_rating := 62
var player_attributes := {"pace": 62, "passing": 60, "shooting": 61, "defending": 58, "goalkeeping": 55}
var league_table := {"Nairobi United": 0, "Red City": 0, "Coastal Rovers": 0, "Highland FC": 0}
var league_records: Dictionary = {}
var opponent_formation := "4-4-2"
var fixture_index := 0
var current_fixture_home := true
var squad_roster: Array = []
var transfer_market: Array = [
    {"name": "Daniel Otieno", "position": "Forward", "rating": 70, "price": 85000, "pace": 74, "passing": 58, "shooting": 72, "defending": 30, "goalkeeping": 20},
    {"name": "Peter Mwangi", "position": "Midfielder", "rating": 68, "price": 70000, "pace": 65, "passing": 73, "shooting": 61, "defending": 58, "goalkeeping": 18},
    {"name": "Samuel Kiptoo", "position": "Defender", "rating": 69, "price": 75000, "pace": 62, "passing": 57, "shooting": 35, "defending": 76, "goalkeeping": 18},
    {"name": "Brian Wekesa", "position": "Goalkeeper", "rating": 67, "price": 65000, "pace": 35, "passing": 50, "shooting": 15, "defending": 30, "goalkeeping": 78}
]
var fixture_results: Array = []
var season_history: Array = []
var active_lineup: Array = []
var controlled_squad_index := 0
var actor_stamina: Dictionary = {}
var keeper_save_cooldown := 0.0
var actor_visuals: Dictionary = {}
var actor_rigs: Dictionary = {}
var keeper_dive_time: Dictionary = {}
var animation_clock := 0.0
var match_events: Array[String] = []
var difficulty_name := "Normal"
var match_duration_minutes := 5
var current_opponent_name := "Red City"
var difficulty_speed_factor := 1.0
var match_duration_seconds := 300.0
var match_paused := false
var pause_overlay: Control
var club_name_input: LineEdit
var club_palette_index := 0
var camera_zoom := 25.0
var selected_club_preset := 0
var last_player_rating := 6.0
var last_team_rating := 6.0
const CLUB_PRESETS := ["Nairobi United", "Mombasa Mariners", "Kisumu Lakeside", "Eldoret Athletic"]
const CLUB_COLORS := [Color(0.10, 0.32, 0.95), Color(0.05, 0.62, 0.72), Color(0.12, 0.62, 0.28), Color(0.78, 0.18, 0.12)]

func _ready() -> void:
	_load_career()
	_ensure_squad()
	_build_world()
	_build_ui()
	_show_menu()

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.82)
	environment.ambient_light_energy = 0.8
	env.environment = environment
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.25
	add_child(sun)

	var field := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(FIELD_LENGTH, FIELD_WIDTH)
	field.mesh = plane
	field.material_override = _mat(Color(0.08, 0.42, 0.16))
	field.position.y = -0.08
	add_child(field)
	_add_static_box(Vector3(0, -0.19, 0), Vector3(FIELD_LENGTH + 4.0, 0.2, FIELD_WIDTH + 4.0))
	# Side boundaries and end-line sections leave the goal mouths open.
	_add_static_box(Vector3(0, 0.55, -FIELD_WIDTH / 2.0 - 0.12), Vector3(FIELD_LENGTH + 1.0, 1.1, 0.24))
	_add_static_box(Vector3(0, 0.55, FIELD_WIDTH / 2.0 + 0.12), Vector3(FIELD_LENGTH + 1.0, 1.1, 0.24))
	for end_side in [-1, 1]:
		var end_x := float(end_side) * (FIELD_LENGTH / 2.0 + 0.12)
		_add_static_box(Vector3(end_x, 0.55, -(FIELD_WIDTH / 2.0 + GOAL_HALF_WIDTH) / 2.0), Vector3(0.24, 1.1, FIELD_WIDTH / 2.0 - GOAL_HALF_WIDTH))
		_add_static_box(Vector3(end_x, 0.55, (FIELD_WIDTH / 2.0 + GOAL_HALF_WIDTH) / 2.0), Vector3(0.24, 1.1, FIELD_WIDTH / 2.0 - GOAL_HALF_WIDTH))
		_add_static_box(Vector3(float(end_side) * (FIELD_LENGTH / 2.0 + 1.8), 1.2, 0), Vector3(0.2, 2.4, GOAL_HALF_WIDTH * 2.0))

	_add_line(Vector3(0, 0.015, 0), Vector3(0, 0.015, FIELD_WIDTH), 0.08)
	_add_line(Vector3(-FIELD_LENGTH/2, 0.015, 0), Vector3(FIELD_LENGTH/2, 0.015, 0), 0.08)
	_add_box_line(Vector3(0, 0.02, -FIELD_WIDTH/2), Vector3(FIELD_LENGTH, 0.08, 0.08))
	_add_box_line(Vector3(0, 0.02, FIELD_WIDTH/2), Vector3(FIELD_LENGTH, 0.08, 0.08))
	_add_box_line(Vector3(-FIELD_LENGTH/2, 0.02, 0), Vector3(0.08, 0.08, FIELD_WIDTH))
	_add_box_line(Vector3(FIELD_LENGTH/2, 0.02, 0), Vector3(0.08, 0.08, FIELD_WIDTH))
	_add_box_line(Vector3(-FIELD_LENGTH/2 + 3, 0.02, 0), Vector3(0.08, 0.08, 9))
	_add_box_line(Vector3(FIELD_LENGTH/2 - 3, 0.02, 0), Vector3(0.08, 0.08, 9))
	_build_goal(1)
	_build_goal(-1)

	player = _make_player(Color(0.1, 0.32, 0.95), Vector3(-8, 0.0, 0))
	player.name = "ControlledPlayer"
	add_child(player)

	# Ten outfield teammates plus the controlled player create an 11-player side.
	for i in range(9):
		var mate := _make_player(Color(0.12, 0.38, 1.0), _formation_position(i))
		add_child(mate)
		teammates.append(mate)
	# Ten opposition outfield players; their goalkeeper is created separately.
	for i in range(10):
		var enemy := _make_player(Color(0.85, 0.12, 0.12), _opponent_formation_position(i))
		add_child(enemy)
		opponents.append(enemy)

	# Dedicated keepers protect both goals and track the ball across the goal mouth.
	var home_keeper := _make_player(Color(0.95, 0.78, 0.12), Vector3(-FIELD_LENGTH / 2.0 + 1.0, 0, 0))
	home_keeper.name = "HomeGoalkeeper"
	add_child(home_keeper)
	goalkeepers.append(home_keeper)
	var away_keeper := _make_player(Color(0.95, 0.78, 0.12), Vector3(FIELD_LENGTH / 2.0 - 1.0, 0, 0))
	away_keeper.name = "AwayGoalkeeper"
	add_child(away_keeper)
	goalkeepers.append(away_keeper)

	ball = RigidBody3D.new()
	ball.name = "Ball"
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	var ball_mesh := MeshInstance3D.new()
	ball_mesh.mesh = sphere
	ball_mesh.material_override = _mat(Color.WHITE)
	ball.add_child(ball_mesh)
	var shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.28
	shape.shape = sphere_shape
	ball.add_child(shape)
	ball.position = Vector3(0, 0.35, 0)
	ball.mass = 0.45
	ball.linear_damp = 0.62
	ball.angular_damp = 0.48
	ball.physics_material_override = PhysicsMaterial.new()
	ball.physics_material_override.bounce = 0.48
	ball.continuous_cd = true
	add_child(ball)

	match_camera = Camera3D.new()
	match_camera.position = Vector3(-8, 25, 25)
	match_camera.rotation_degrees = Vector3(-42, 0, 0)
	match_camera.current = true
	add_child(match_camera)

func _add_static_box(at: Vector3, dimensions: Vector3) -> void:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = dimensions
	collision.shape = box
	body.add_child(collision)
	body.position = at
	add_child(body)

func _build_goal(side: int) -> void:
	# Goals sit on the two end lines. The posts and crossbar have solid collision.
	var x := float(side) * FIELD_LENGTH / 2.0
	var post_material := _mat(Color.WHITE)
	_add_goal_part(Vector3(x, GOAL_HEIGHT / 2.0, -GOAL_HALF_WIDTH), Vector3(0.18, GOAL_HEIGHT, 0.18), post_material)
	_add_goal_part(Vector3(x, GOAL_HEIGHT / 2.0, GOAL_HALF_WIDTH), Vector3(0.18, GOAL_HEIGHT, 0.18), post_material)
	_add_goal_part(Vector3(x, GOAL_HEIGHT, 0), Vector3(0.18, 0.18, GOAL_HALF_WIDTH * 2.0), post_material)
	# A visible, lightweight net frame behind the goal line.
	var net_material := _mat(Color(0.82, 0.88, 0.9, 0.32))
	_add_goal_part(Vector3(x - side * 1.0, GOAL_HEIGHT / 2.0, 0), Vector3(0.08, GOAL_HEIGHT, GOAL_HALF_WIDTH * 2.0), net_material, false)
	_add_goal_part(Vector3(x - side * 0.5, GOAL_HEIGHT / 2.0, -GOAL_HALF_WIDTH), Vector3(1.0, GOAL_HEIGHT, 0.08), net_material, false)
	_add_goal_part(Vector3(x - side * 0.5, GOAL_HEIGHT / 2.0, GOAL_HALF_WIDTH), Vector3(1.0, GOAL_HEIGHT, 0.08), net_material, false)

func _add_goal_part(at: Vector3, dimensions: Vector3, material: Material, solid: bool = true) -> void:
	var holder: Node3D
	if solid:
		holder = StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var collision_box := BoxShape3D.new()
		collision_box.size = dimensions
		collision.shape = collision_box
		holder.add_child(collision)
	else:
		holder = Node3D.new()
	var visual := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	visual.mesh = box
	visual.material_override = material
	holder.add_child(visual)
	holder.position = at
	add_child(holder)

func _make_player(color: Color, at: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.position = at
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.48
	capsule.height = 1.8
	var mesh := MeshInstance3D.new()
	mesh.mesh = capsule
	mesh.material_override = _mat(color)
	mesh.position.y = 0.9
	body.add_child(mesh)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.24
	head_mesh.height = 0.48
	head.mesh = head_mesh
	head.material_override = _mat(Color(0.72, 0.48, 0.32))
	head.position = Vector3(0, 1.94, 0)
	body.add_child(head)
	var leg_material := _mat(Color(0.10, 0.12, 0.18))
	var left_leg := MeshInstance3D.new()
	var leg_mesh := CapsuleMesh.new()
	leg_mesh.radius = 0.13
	leg_mesh.height = 0.72
	left_leg.mesh = leg_mesh
	left_leg.material_override = leg_material
	left_leg.position = Vector3(-0.19, 0.39, 0)
	body.add_child(left_leg)
	var right_leg := MeshInstance3D.new()
	right_leg.mesh = leg_mesh
	right_leg.material_override = leg_material
	right_leg.position = Vector3(0.19, 0.39, 0)
	body.add_child(right_leg)
	var left_arm := MeshInstance3D.new()
	var arm_mesh := CapsuleMesh.new()
	arm_mesh.radius = 0.105
	arm_mesh.height = 0.72
	left_arm.mesh = arm_mesh
	left_arm.material_override = _mat(color.darkened(0.12))
	left_arm.position = Vector3(-0.53, 0.98, 0)
	left_arm.rotation.z = -0.22
	body.add_child(left_arm)
	var right_arm := MeshInstance3D.new()
	right_arm.mesh = arm_mesh
	right_arm.material_override = _mat(color.darkened(0.12))
	right_arm.position = Vector3(0.53, 0.98, 0)
	right_arm.rotation.z = 0.22
	body.add_child(right_arm)
	actor_visuals[body.get_instance_id()] = mesh
	actor_rigs[body.get_instance_id()] = {"head": head, "left_leg": left_leg, "right_leg": right_leg, "left_arm": left_arm, "right_arm": right_arm}
	actor_stamina[body.get_instance_id()] = 100.0
	keeper_dive_time[body.get_instance_id()] = 0.0
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.48
	shape.height = 1.8
	collision.shape = shape
	collision.position.y = 0.9
	body.add_child(collision)
	return body

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material

func _add_line(a: Vector3, b: Vector3, width: float) -> void:
	var length := a.distance_to(b)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(width, 0.04, length)
	mesh.mesh = box
	mesh.material_override = _mat(Color.WHITE)
	mesh.position = (a + b) / 2
	add_child(mesh)

func _add_box_line(pos: Vector3, size: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _mat(Color.WHITE)
	mesh.position = pos
	add_child(mesh)

func _build_ui() -> void:
	screen_root = Control.new()
	screen_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_root)

func _clear_ui() -> void:
	for child in screen_root.get_children():
		child.queue_free()

func _show_menu() -> void:
	get_tree().paused = false
	match_paused = false
	match_running = false
	_clear_ui()
	var panel := _panel()
	var title := _label("OFFLINE FOOTBALL", 34)
	panel.add_child(title)
	panel.add_child(_label("3D MATCHES  •  CLUB MANAGEMENT  •  NO INTERNET", 16))
	panel.add_child(_label("Club: " + str(career.club), 22))
	panel.add_child(_label("Season %s   |   Played %s   |   Wins %s   |   Points %s" % [career.season, career.played, career.wins, career.points], 17))
	panel.add_child(_label("Transfer budget: KSh " + str(career.cash), 17))
	panel.add_child(_make_button("PLAY EXHIBITION MATCH", _start_match))
	panel.add_child(_make_button("CAREER MODE", _show_career))
	panel.add_child(_make_button("CLUB IDENTITY & TEAM SELECTION", _show_club_identity))
	panel.add_child(_make_button("GAME SETTINGS", _show_settings))
	panel.add_child(_make_button("RESET CAREER", _reset_career))

func _show_career() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("CLUB MANAGEMENT", 32))
	panel.add_child(_label(str(career.club) + "  |  Season " + str(career.season), 22))
	panel.add_child(_label("League points: %s    Wins: %s    Matches: %s" % [career.points, career.wins, career.played], 18))
	panel.add_child(_label("Transfer budget: KSh " + str(career.cash), 18))
	panel.add_child(_label("Squad rating: %s   |   Formation: %s   |   Tactic: %s" % [squad_rating, formation_name, team_tactic], 18))
	panel.add_child(_label("Training focus: " + training_focus, 16))
	var unavailable_count := 0
	var tired_count := 0
	for member in squad_roster:
		_ensure_player_condition(member)
		if not _player_available(member):
			unavailable_count += 1
		if int(member.get("fitness", 100)) < 50:
			tired_count += 1
	panel.add_child(_label("Squad condition: %d unavailable | %d low-fitness players" % [unavailable_count, tired_count], 15))
	panel.add_child(_label("Attributes  Pace %s | Pass %s | Shoot %s | Defend %s" % [player_attributes.pace, player_attributes.passing, player_attributes.shooting, player_attributes.defending], 15))
	panel.add_child(_label("League: " + _league_summary(), 15))
	panel.add_child(_make_button("CHANGE FORMATION", _cycle_formation))
	panel.add_child(_make_button("CHANGE TEAM TACTIC", _cycle_team_tactic))
	panel.add_child(_make_button("CHANGE TRAINING FOCUS", _cycle_training_focus))
	panel.add_child(_make_button("TRAIN: %s  (- KSh 10,000)" % training_focus.to_upper(), _train_team))
	panel.add_child(_make_button("SQUAD & PLAYER ROLES", _show_squad))
	panel.add_child(_make_button("TRANSFER MARKET", _show_transfer_market))
	panel.add_child(_make_button("FIXTURES & RESULTS", _show_fixtures))
	panel.add_child(_make_button("VIEW LEAGUE TABLE", _show_league_table))
	panel.add_child(_make_button("PLAY NEXT LEAGUE MATCH", _start_career_match))
	panel.add_child(_make_button("BACK TO MAIN MENU", _show_menu))


func _show_club_identity() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("CLUB IDENTITY", 32))
	panel.add_child(_label("Choose a club identity and home kit colour. Your career record is retained.", 16))
	panel.add_child(_label("Club preset: " + str(career.get("club", "Nairobi United")), 20))
	panel.add_child(_make_button("CYCLE CLUB PRESET", _cycle_club_preset))
	panel.add_child(_label("Home kit colour: " + _kit_colour_name(), 18))
	panel.add_child(_make_button("CHANGE HOME KIT COLOUR", _cycle_kit_colour))
	club_name_input = LineEdit.new()
	club_name_input.text = str(career.get("club", "Nairobi United"))
	club_name_input.placeholder_text = "Enter club name"
	club_name_input.custom_minimum_size = Vector2(220, 48)
	panel.add_child(club_name_input)
	panel.add_child(_make_button("SAVE CLUB NAME", _save_club_identity))
	panel.add_child(_make_button("BACK TO MAIN MENU", _show_menu))

func _cycle_club_preset() -> void:
	selected_club_preset = posmod(selected_club_preset + 1, CLUB_PRESETS.size())
	var previous_name := str(career.get("club", "Nairobi United"))
	var next_name := CLUB_PRESETS[selected_club_preset]
	career["club"] = next_name
	if league_table.has(previous_name):
		league_table[next_name] = int(league_table.get(next_name, league_table[previous_name]))
		if previous_name != next_name:
			league_table.erase(previous_name)
	_save_career()
	_show_club_identity()

func _kit_colour_name() -> String:
	return ["Royal Blue", "Ocean Teal", "Forest Green", "Crimson"][club_palette_index]

func _cycle_kit_colour() -> void:
	club_palette_index = posmod(club_palette_index + 1, CLUB_COLORS.size())
	_apply_team_colours()
	_save_career()
	_show_club_identity()

func _apply_team_colours() -> void:
	var home_color: Color = CLUB_COLORS[club_palette_index]
	for actor in [player] + teammates:
		if is_instance_valid(actor):
			var visual := actor_visuals.get(actor.get_instance_id()) as MeshInstance3D
			if is_instance_valid(visual):
				visual.material_override = _mat(home_color)
	var away_color := Color(0.85, 0.12, 0.12)
	if current_opponent_name == "Coastal Rovers":
		away_color = Color(0.95, 0.58, 0.08)
	elif current_opponent_name == "Highland FC":
		away_color = Color(0.48, 0.18, 0.72)
	for actor in opponents:
		if is_instance_valid(actor):
			var visual := actor_visuals.get(actor.get_instance_id()) as MeshInstance3D
			if is_instance_valid(visual):
				visual.material_override = _mat(away_color)

func _save_club_identity() -> void:
	if not is_instance_valid(club_name_input):
		return
	var proposed_name := club_name_input.text.strip_edges()
	if proposed_name.length() < 3 or proposed_name.length() > 24:
		club_name_input.text = str(career.get("club", "Nairobi United"))
		return
	var previous_name := str(career.get("club", "Nairobi United"))
	career["club"] = proposed_name
	if league_table.has(previous_name):
		var old_points: int = int(league_table[previous_name])
		league_table.erase(previous_name)
		league_table[proposed_name] = old_points
	_save_career()
	_show_menu()

func _show_settings() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("GAME SETTINGS", 32))
	panel.add_child(_label("Choose match difficulty and match length", 17))
	panel.add_child(_label("Difficulty: %s" % difficulty_name, 21))
	panel.add_child(_make_button("CHANGE DIFFICULTY", _cycle_difficulty))
	panel.add_child(_label("Match length: %d minutes" % match_duration_minutes, 21))
	panel.add_child(_make_button("CHANGE MATCH LENGTH", _cycle_match_duration))
	panel.add_child(_label("Settings are saved locally on this device.", 14))
	panel.add_child(_make_button("BACK TO MAIN MENU", _show_menu))

func _cycle_difficulty() -> void:
	if difficulty_name == "Easy":
		difficulty_name = "Normal"
		difficulty_speed_factor = 1.0
	elif difficulty_name == "Normal":
		difficulty_name = "Hard"
		difficulty_speed_factor = 1.18
	else:
		difficulty_name = "Easy"
		difficulty_speed_factor = 0.82
	_save_career()
	_show_settings()

func _cycle_match_duration() -> void:
	if match_duration_minutes == 3:
		match_duration_minutes = 5
	elif match_duration_minutes == 5:
		match_duration_minutes = 8
	else:
		match_duration_minutes = 3
	_save_career()
	_show_settings()

func _opponent_for_fixture(index: int) -> String:
	# Six league rounds: each of the three rivals is played once at home
	# and once away. The order is deliberately mirrored for the return legs.
	var schedule := ["Red City", "Coastal Rovers", "Highland FC", "Highland FC", "Coastal Rovers", "Red City"]
	return str(schedule[posmod(index, schedule.size())])

func _fixture_home_for_club(index: int) -> bool:
	return posmod(index, 6) < 3

func _fixture_description(index: int) -> String:
	var club_name := str(career.get("club", "Nairobi United"))
	var opponent_name := _opponent_for_fixture(index)
	if _fixture_home_for_club(index):
		return "%s vs %s" % [club_name, opponent_name]
	return "%s vs %s" % [opponent_name, club_name]

func _cycle_training_focus() -> void:
	var current_index := TRAINING_FOCUSES.find(training_focus)
	training_focus = TRAINING_FOCUSES[posmod(current_index + 1, TRAINING_FOCUSES.size())]
	_save_career()
	_show_career()

func _train_team() -> void:
	if int(career.cash) >= 10000:
		career.cash = int(career.cash) - 10000
		var trained_attribute := ""
		match training_focus:
			"Fitness":
				for member in squad_roster:
					member["fitness"] = mini(100, int(member.get("fitness", 100)) + 20)
			"Attacking":
				trained_attribute = "shooting"
			"Passing":
				trained_attribute = "passing"
			"Defending":
				trained_attribute = "defending"
			"Goalkeeping":
				trained_attribute = "goalkeeping"
			_:
				trained_attribute = "all"
		if trained_attribute == "all":
			for key in player_attributes.keys():
				player_attributes[key] = mini(99, int(player_attributes[key]) + 1)
			for member in squad_roster:
				member["fitness"] = mini(100, int(member.get("fitness", 100)) + 8)
		elif not trained_attribute.is_empty():
			player_attributes[trained_attribute] = mini(99, int(player_attributes.get(trained_attribute, 60)) + 2)
			squad_rating = mini(99, squad_rating + 1)
		_save_career()
	_show_career()

func _ensure_player_condition(member: Dictionary) -> void:
	member["fitness"] = clampi(int(member.get("fitness", 100)), 0, 100)
	member["injury_matches"] = maxi(0, int(member.get("injury_matches", 0)))
	member["suspension_matches"] = maxi(0, int(member.get("suspension_matches", 0)))
	member["yellow_cards_season"] = maxi(0, int(member.get("yellow_cards_season", 0)))

func _player_available(member: Dictionary) -> bool:
	_ensure_player_condition(member)
	return int(member.get("injury_matches", 0)) == 0 and int(member.get("suspension_matches", 0)) == 0

func _process_squad_after_match() -> void:
	# One career fixture represents one recovery week. Players who featured tire;
	# reserves recover. Injury duration is measured in upcoming career fixtures.
	for member in squad_roster:
		_ensure_player_condition(member)
		if int(member.get("injury_matches", 0)) > 0:
			member["injury_matches"] = maxi(0, int(member["injury_matches"]) - 1)
		if int(member.get("suspension_matches", 0)) > 0:
			member["suspension_matches"] = maxi(0, int(member["suspension_matches"]) - 1)
		if active_lineup.has(member):
			member["fitness"] = maxi(20, int(member.get("fitness", 100)) - 12)
		else:
			member["fitness"] = mini(100, int(member.get("fitness", 100)) + 18)
		# Very tired players have a small chance of missing the next fixture.
		if active_lineup.has(member) and int(member.get("fitness", 100)) <= 30 and int(member.get("injury_matches", 0)) == 0 and randf() < 0.12:
			member["injury_matches"] = randi_range(1, 2)
			_record_match_event("%s picked up an injury and will miss %d fixture(s)" % [member.get("name", "A player"), member["injury_matches"]])

func _league_summary() -> String:
	var parts: Array[String] = []
	for club_name in league_table.keys():
		parts.append("%s %s" % [club_name, league_table[club_name]])
	return "  •  ".join(parts)

func _ensure_league_record(club_name: String) -> void:
	if not league_records.has(club_name):
		league_records[club_name] = {"played": 0, "won": 0, "drawn": 0, "lost": 0, "gf": 0, "ga": 0, "points": int(league_table.get(club_name, 0)), "form": []}

func _update_league_record(club_name: String, scored: int, conceded: int) -> void:
	_ensure_league_record(club_name)
	var record: Dictionary = league_records[club_name]
	record.played = int(record.get("played", 0)) + 1
	record.gf = int(record.get("gf", 0)) + scored
	record.ga = int(record.get("ga", 0)) + conceded
	var result_code := "D"
	if scored > conceded:
		record.won = int(record.get("won", 0)) + 1
		record.points = int(record.get("points", 0)) + 3
		result_code = "W"
	elif scored == conceded:
		record.drawn = int(record.get("drawn", 0)) + 1
		record.points = int(record.get("points", 0)) + 1
	else:
		record.lost = int(record.get("lost", 0)) + 1
		result_code = "L"
	var form: Array = record.get("form", [])
	form.append(result_code)
	while form.size() > 5:
		form.pop_front()
	record["form"] = form
	league_records[club_name] = record

func _simulate_other_league_fixture(round_index: int) -> Dictionary:
	# The other match in each four-club round is simulated locally so every
	# club accumulates a complete league record, not only the user's opponents.
	var remaining_fixtures := [
		["Coastal Rovers", "Highland FC"],
		["Highland FC", "Red City"],
		["Red City", "Coastal Rovers"],
		["Highland FC", "Coastal Rovers"],
		["Red City", "Highland FC"],
		["Coastal Rovers", "Red City"]
	]
	var pairing: Array = remaining_fixtures[posmod(round_index, remaining_fixtures.size())]
	var home_name := str(pairing[0])
	var away_name := str(pairing[1])
	var home_goals := randi_range(0, 3)
	var away_goals := randi_range(0, 3)
	_update_league_record(home_name, home_goals, away_goals)
	_update_league_record(away_name, away_goals, home_goals)
	if home_goals > away_goals:
		league_table[home_name] = int(league_table.get(home_name, 0)) + 3
	elif home_goals == away_goals:
		league_table[home_name] = int(league_table.get(home_name, 0)) + 1
		league_table[away_name] = int(league_table.get(away_name, 0)) + 1
	else:
		league_table[away_name] = int(league_table.get(away_name, 0)) + 3
	return {"home": home_name, "away": away_name, "score": "%d-%d" % [home_goals, away_goals]}

func _league_ranking_names() -> Array:
	for club_name in league_table.keys():
		_ensure_league_record(str(club_name))
	var ordered := league_table.keys()
	ordered.sort_custom(func(a, b):
		var ra: Dictionary = league_records[str(a)]
		var rb: Dictionary = league_records[str(b)]
		var pa := int(ra.get("points", league_table[a]))
		var pb := int(rb.get("points", league_table[b]))
		if pa != pb:
			return pa > pb
		var ga := int(ra.get("gf", 0)) - int(ra.get("ga", 0))
		var gb := int(rb.get("gf", 0)) - int(rb.get("ga", 0))
		if ga != gb:
			return ga > gb
		var gfa := int(ra.get("gf", 0))
		var gfb := int(rb.get("gf", 0))
		if gfa != gfb:
			return gfa > gfb
		var wa := int(ra.get("won", 0))
		var wb := int(rb.get("won", 0))
		if wa != wb:
			return wa > wb
		return str(a) < str(b)
	)
	return ordered

func _archive_completed_season() -> void:
	var ordered := _league_ranking_names()
	if ordered.is_empty():
		return
	var final_table: Array = []
	for index in range(ordered.size()):
		var club_name := str(ordered[index])
		var record: Dictionary = league_records.get(club_name, {})
		final_table.append({
			"position": index + 1,
			"club": club_name,
			"played": int(record.get("played", 0)),
			"won": int(record.get("won", 0)),
			"drawn": int(record.get("drawn", 0)),
			"lost": int(record.get("lost", 0)),
			"gf": int(record.get("gf", 0)),
			"ga": int(record.get("ga", 0)),
			"points": int(record.get("points", league_table.get(club_name, 0)))
		})
	season_history.append({
		"season": int(career.get("season", 1)),
		"champion": str(ordered[0]),
		"runner_up": str(ordered[1]) if ordered.size() > 1 else "",
		"table": final_table
	})
	while season_history.size() > 20:
		season_history.pop_front()

func _show_league_table() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("LEAGUE TABLE", 32))
	for club_name in league_table.keys():
		_ensure_league_record(str(club_name))
	var ordered := _league_ranking_names()
	panel.add_child(_label("POS  CLUB                 P  W  D  L   GF GA GD PTS", 13))
	for index in range(ordered.size()):
		var club_name := str(ordered[index])
		var r: Dictionary = league_records[club_name]
		var gd := int(r.get("gf", 0)) - int(r.get("ga", 0))
		panel.add_child(_label("%d. %s   %d  %d  %d  %d   %d  %d %+d  %d" % [index + 1, club_name, r.get("played", 0), r.get("won", 0), r.get("drawn", 0), r.get("lost", 0), r.get("gf", 0), r.get("ga", 0), gd, league_table[club_name]], 14))
		var form: Array = r.get("form", [])
		panel.add_child(_label("Recent form: %s" % (" - ".join(form) if not form.is_empty() else "No matches"), 12))
	panel.add_child(_label("Ranking: Points → Goal difference → Goals scored → Wins → Club name", 12))
	panel.add_child(_make_button("BACK TO CLUB", _show_career))

func _start_match() -> void:
	_begin_match(false)

func _start_career_match() -> void:
	_begin_match(true)

func _begin_match(is_career: bool) -> void:
	get_tree().paused = false
	match_paused = false
	if is_instance_valid(match_timer):
		match_timer.queue_free()
	_clear_ui()
	score_home = 0
	score_away = 0
	match_duration_seconds = float(match_duration_minutes * 60)
	seconds_left = match_duration_seconds
	current_opponent_name = _opponent_for_fixture(fixture_index) if is_career else "Red City"
	current_fixture_home = _fixture_home_for_club(fixture_index) if is_career else true
	_apply_team_colours()
	match_running = true
	match_paused = false
	current_match_is_career = is_career
	opponent_shot_cooldown = 0.8
	opponent_action_cooldown = 0.5
	ball_reset_lock = 0.8
	keeper_save_cooldown = 0.0
	actor_stamina.clear()
	actor_stamina[player.get_instance_id()] = 100.0
	for stamina_actor in teammates + opponents + goalkeepers:
		actor_stamina[stamina_actor.get_instance_id()] = 100.0
	tackle_cooldown = 0.0
	switch_cooldown = 0.0
	foul_count = 0
	yellow_cards_home = 0
	red_cards_home = 0
	player_sent_off = false
	pending_offside_actor_id = 0
	offside_check_cooldown = 0.0
	restart_type = "None"
	last_touch_home = true
	restart_for_home = true
	match_stats = {"shots": 0, "shots_on_target": 0, "saves": 0, "passes": 0, "tackles": 0, "possession_ticks": 0, "opponent_ticks": 0}
	match_events.clear()
	animation_clock = 0.0
	substitutions_used = 0
	active_lineup = _get_starting_lineup()
	controlled_squad_index = _find_controlled_lineup_index()
	player.position = Vector3(-7.0, 0, 0)
	goalkeepers[0].position = Vector3(-FIELD_LENGTH / 2.0 + 1.0, 0, 0)
	goalkeepers[1].position = Vector3(FIELD_LENGTH / 2.0 - 1.0, 0, 0)
	for i in range(opponents.size()):
		opponents[i].position = _opponent_formation_position(i)
	for i in range(teammates.size()):
		var lineup_slot := i if i < controlled_squad_index else i + 1
		teammates[i].position = _formation_position(lineup_slot)
	ball.position = Vector3(0, 0.35, 0)
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	var panel := _panel()
	hud = _label("%s  0 - 0  %s   |   %02d:00" % [str(career.get("club", "Nairobi United")), current_opponent_name, match_duration_minutes], 22)
	panel.add_child(hud)
	var selected_name := str(active_lineup[controlled_squad_index].get("name", "Player")) if controlled_squad_index < active_lineup.size() else "Player"
	status_label = _label("%s difficulty | Controlling %s. Hold a direction to move; SHOOT near the ball." % [difficulty_name, selected_name], 14)
	panel.add_child(status_label)
	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(controls)
	controls.add_child(_make_hold_button("◀", Vector2.LEFT))
	controls.add_child(_make_hold_button("▲", Vector2.UP))
	controls.add_child(_make_hold_button("▼", Vector2.DOWN))
	controls.add_child(_make_hold_button("▶", Vector2.RIGHT))
	controls.add_child(_make_button("SHOOT", _shoot))
	var action_row := HBoxContainer.new()
	panel.add_child(action_row)
	action_row.add_child(_make_button("PASS", _pass_ball))
	action_row.add_child(_make_button("TACKLE", _tackle))
	action_row.add_child(_make_button("SWITCH", _switch_player))
	var action_row_two := HBoxContainer.new()
	panel.add_child(action_row_two)
	action_row_two.add_child(_make_button("SUBSTITUTE", _make_substitution))
	action_row_two.add_child(_make_button("FREE KICK", _take_free_kick))
	action_row_two.add_child(_make_button("ZOOM +", _zoom_camera_in))
	action_row_two.add_child(_make_button("ZOOM -", _zoom_camera_out))
	panel.add_child(_make_button("PAUSE MATCH", _pause_match))
	panel.add_child(_make_button("RESTART MATCH", func(): _begin_match(is_career)))
	panel.add_child(_make_button("END MATCH", func(): _finish_match(is_career)))
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.timeout.connect(func(): _tick(is_career))
	add_child(timer)
	timer.start()
	match_timer = timer

func _zoom_camera_in() -> void:
	camera_zoom = clampf(camera_zoom - 3.0, 17.0, 34.0)

func _zoom_camera_out() -> void:
	camera_zoom = clampf(camera_zoom + 3.0, 17.0, 34.0)

func _pause_match() -> void:
	if not match_running or match_paused:
		return
	match_paused = true
	move_vector = Vector2.ZERO
	get_tree().paused = true
	pause_overlay = Control.new()
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	screen_root.add_child(pause_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.06, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(shade)
	var panel := VBoxContainer.new()
	panel.anchor_left = 0.18
	panel.anchor_right = 0.82
	panel.anchor_top = 0.24
	panel.anchor_bottom = 0.76
	panel.add_theme_constant_override("separation", 16)
	pause_overlay.add_child(panel)
	panel.add_child(_label("MATCH PAUSED", 34))
	panel.add_child(_label("The match clock and player movement are stopped.", 16))
	panel.add_child(_make_button("RESUME MATCH", _resume_match))
	panel.add_child(_make_button("RESTART MATCH", func(): _begin_match(current_match_is_career)))
	panel.add_child(_make_button("END MATCH", func(): _finish_match(current_match_is_career)))

func _resume_match() -> void:
	get_tree().paused = false
	match_paused = false
	if is_instance_valid(pause_overlay):
		pause_overlay.queue_free()
	pause_overlay = null

func _tick(is_career: bool) -> void:
	if not match_running:
		if is_instance_valid(match_timer):
			match_timer.queue_free()
		return
	if match_paused:
		return
	var delta := 0.2
	animation_clock += delta
	seconds_left -= delta
	opponent_shot_cooldown = maxf(0.0, opponent_shot_cooldown - delta)
	opponent_action_cooldown = maxf(0.0, opponent_action_cooldown - delta)
	ball_reset_lock = maxf(0.0, ball_reset_lock - delta)
	tackle_cooldown = maxf(0.0, tackle_cooldown - delta)
	offside_check_cooldown = maxf(0.0, offside_check_cooldown - delta)
	switch_cooldown = maxf(0.0, switch_cooldown - delta)
	var direction := Vector3(move_vector.x, 0, move_vector.y)
	var controlled_rating := _lineup_rating(controlled_squad_index)
	var controlled_stamina := _stamina_for(player)
	var stamina_factor := 0.62 + controlled_stamina / 260.0
	var dismissal_factor := 0.88 if player_sent_off else 1.0
	var controlled_speed := PLAYER_SPEED * (0.82 + float(controlled_rating) / 350.0) * stamina_factor * dismissal_factor
	if direction.length() > 0.05:
		_set_stamina(player, controlled_stamina - delta * 2.1)
	else:
		_set_stamina(player, controlled_stamina + delta * 1.25)
	player.velocity = direction.normalized() * controlled_speed
	player.move_and_slide()
	_animate_actor(player, direction.length() > 0.05, delta)
	player.position.x = clampf(player.position.x, -FIELD_LENGTH/2 + 1, FIELD_LENGTH/2 - 1)
	player.position.z = clampf(player.position.z, -FIELD_WIDTH/2 + 1, FIELD_WIDTH/2 - 1)

	# Tactical opposition: nearest player presses, others recover into a compact block.
	var press_index := 0
	var press_distance := INF
	for i in range(opponents.size()):
		var distance_to_ball := opponents[i].global_position.distance_to(ball.global_position)
		if distance_to_ball < press_distance:
			press_distance = distance_to_ball
			press_index = i
	for i in range(opponents.size()):
		var enemy := opponents[i]
		var tactical_target := _opponent_tactical_target(i, press_index)
		var to_target := tactical_target - enemy.global_position
		to_target.y = 0
		if to_target.length() > 0.8:
			var enemy_stamina := _stamina_for(enemy)
			var enemy_factor := 0.68 + enemy_stamina / 310.0
			enemy.velocity = to_target.normalized() * (AI_SPEED if i == press_index else AI_SPEED * 0.72) * enemy_factor * difficulty_speed_factor
			_set_stamina(enemy, enemy_stamina - delta * 0.75)
			enemy.move_and_slide()
			_animate_actor(enemy, true, delta)
		else:
			enemy.velocity = Vector3.ZERO
			_animate_actor(enemy, false, delta)
			_set_stamina(enemy, _stamina_for(enemy) + delta * 1.1)
		# The opposition chooses between a shot, a forward pass and a carry
		# using goal distance, nearby pressure and the position of its runners.
		if i == press_index and press_distance < 1.4 and player.global_position.distance_to(ball.global_position) > 1.55:
			_opponent_attack_decision()
	if player.global_position.distance_to(ball.global_position) < 2.0:
		match_stats.possession_ticks = int(match_stats.possession_ticks) + 1
	else:
		match_stats.opponent_ticks = int(match_stats.opponent_ticks) + 1

	# Goalkeepers slide laterally to cover the ball's position in their penalty area.
	for i in range(goalkeepers.size()):
		var keeper := goalkeepers[i]
		var defending_left := i == 0
		var ball_is_threatening := ball.global_position.x < -7.0 if defending_left else ball.global_position.x > 7.0
		var shot_approach := ball.linear_velocity.x < -0.5 if defending_left else ball.linear_velocity.x > 0.5
		var anticipation := ball.linear_velocity.z * 0.22 if ball_is_threatening and shot_approach else 0.0
		var keeper_target := _goalkeeper_anticipation_target(defending_left, ball_is_threatening, shot_approach, anticipation)
		var keeper_delta := keeper_target - keeper.position
		if keeper_delta.length() > 0.12:
			var keeper_speed := 3.4 + (0.8 if ball.linear_velocity.length() > 5.0 and ball_is_threatening else 0.0)
			keeper.velocity = keeper_delta.normalized() * keeper_speed
			keeper.move_and_slide()
			_animate_actor(keeper, true, delta)
		else:
			keeper.velocity = Vector3.ZERO
			_animate_actor(keeper, false, delta)
		var incoming_speed := ball.linear_velocity.length()
		var save_radius := 1.45 + minf(0.35, incoming_speed * 0.035)
		if keeper_save_cooldown <= 0.0 and ball.global_position.distance_to(keeper.global_position) < save_radius and ball.global_position.y < 2.0:
			var clearance := Vector3(1.0, 0.42, signf(ball.global_position.z - keeper.global_position.z) * 0.75)
			clearance.x = 1.0 if defending_left else -1.0
			ball.apply_central_impulse(clearance.normalized() * (7.2 + minf(1.8, incoming_speed * 0.12)))
			keeper_save_cooldown = 0.9
			match_stats.saves = int(match_stats.get("saves", 0)) + 1
			_record_match_event("Goalkeeper makes a save")
			keeper_dive_time[keeper.get_instance_id()] = 0.42
			var keeper_rig: Dictionary = actor_rigs.get(keeper.get_instance_id(), {})
			var keeper_arm := keeper_rig.get("left_arm") as MeshInstance3D
			var keeper_other_arm := keeper_rig.get("right_arm") as MeshInstance3D
			if is_instance_valid(keeper_arm) and is_instance_valid(keeper_other_arm):
				keeper_arm.rotation.z = -1.05 if defending_left else -0.65
				keeper_other_arm.rotation.z = 1.05 if defending_left else 0.65
			_record_match_event("Goalkeeper save")
			status_label.text = "Goalkeeper makes a save!"

	# Teammates use coordinated forward runs, midfield passing support and
	# selective full-back overlaps instead of moving as isolated formation dots.
	for i in range(teammates.size()):
		var mate := teammates[i]
		var roster_index := i if i < controlled_squad_index else i + 1
		var role := _lineup_position(roster_index)
		var target := _teammate_tactical_target(roster_index, role, _formation_position(roster_index))
		var support := target - mate.position
		if support.length() > 0.7:
			var mate_rating := _lineup_rating(roster_index)
			var mate_stamina := _stamina_for(mate)
			var mate_factor := 0.7 + mate_stamina / 330.0
			mate.velocity = support.normalized() * (1.0 + float(mate_rating) / 100.0) * mate_factor
			_set_stamina(mate, mate_stamina - delta * 0.5)
			mate.move_and_slide()
			_animate_actor(mate, true, delta)
		else:
			_animate_actor(mate, false, delta)
			_set_stamina(mate, _stamina_for(mate) + delta * 0.9)

	keeper_save_cooldown = maxf(0.0, keeper_save_cooldown - delta)
	# Close control: keep the ball within playable reach and nudge it into the
	# player's running lane without snapping or teleporting the physics body.
	var ball_distance := player.global_position.distance_to(ball.global_position)
	if ball_distance < 1.45 and ball.global_position.y < 0.9:
		if direction.length() > 0.05:
			var dribble_push := direction.normalized() * (0.34 if ball_distance < 0.9 else 0.46)
			dribble_push.y = 0.025
			ball.apply_central_impulse(dribble_push)
		else:
			ball.linear_velocity.x *= 0.91
			ball.linear_velocity.z *= 0.91
	_check_offside()
	_check_goal()
	_handle_ball_out()
	# Keep the broadcast-style camera centred on the active play, with a safe field-height view.
	if is_instance_valid(match_camera):
		var camera_target := Vector3(player.position.x * 0.58 + ball.position.x * 0.42, 0, player.position.z * 0.45 + ball.position.z * 0.55)
		var desired_camera := camera_target + Vector3(-2.0, camera_zoom, camera_zoom)
		match_camera.position = match_camera.position.lerp(desired_camera, 0.045)
		match_camera.look_at(camera_target, Vector3.UP)
	if player.global_position.distance_to(ball.global_position) < 1.6:
		status_label.text = "Ball nearby | Stamina %d%% | Shots %d | Passes %d" % [int(_stamina_for(player)), int(match_stats.shots), int(match_stats.passes)]
	if seconds_left <= 0:
		_finish_match(is_career)
	else:
		hud.text = "%s  %d - %d  %s   |   %02d:%02d   |   %s" % [str(career.get("club", "Nairobi United")), score_home, score_away, current_opponent_name, int(seconds_left) / 60, int(seconds_left) % 60, formation_name]

func _opponent_attack_decision() -> void:
	var goal_distance := absf(ball.global_position.x + FIELD_LENGTH / 2.0)
	var nearest_pressure := player.global_position.distance_to(ball.global_position)
	for mate in teammates:
		nearest_pressure = minf(nearest_pressure, mate.global_position.distance_to(ball.global_position))
	var best_runner: CharacterBody3D = null
	var best_score := -INF
	for runner in opponents:
		if runner.global_position.x >= ball.global_position.x - 0.8:
			continue
		var forward_gain := ball.global_position.x - runner.global_position.x
		var lane_space := 1.0
		for defender in teammates:
			lane_space = minf(lane_space, runner.global_position.distance_to(defender.global_position))
		var score := forward_gain * 0.7 + minf(lane_space, 7.0) * 0.55
		if score > best_score:
			best_score = score
			best_runner = runner
	var can_shoot := goal_distance < 11.0 and absf(ball.global_position.z) < 8.0
	if can_shoot and opponent_shot_cooldown <= 0.0 and (nearest_pressure > 1.8 or goal_distance < 6.0):
		var shot_target := Vector3(-FIELD_LENGTH / 2.0 - 1.0, 0.9, clampf(-ball.global_position.z * 0.16, -1.8, 1.8))
		var shot_direction := (shot_target - ball.global_position).normalized()
		ball.apply_central_impulse(shot_direction * (6.8 + 0.75 * difficulty_speed_factor))
		last_touch_home = false
		opponent_shot_cooldown = 1.8
		_record_match_event("Opposition shot")
	elif best_runner != null and opponent_action_cooldown <= 0.0 and (nearest_pressure < 3.2 or best_score > 7.0):
		var pass_target := best_runner.global_position + Vector3(-1.0, 0.25, 0.0)
		var pass_direction := (pass_target - ball.global_position).normalized()
		ball.apply_central_impulse(pass_direction * (4.0 + 0.35 * difficulty_speed_factor))
		last_touch_home = false
		opponent_action_cooldown = 1.25
		_record_match_event("Opposition builds an attack — forward pass")
	else:
		var carry_direction := Vector3(-1.0, 0.035, clampf(-ball.global_position.z * 0.035, -0.3, 0.3)).normalized()
		ball.apply_central_impulse(carry_direction * 0.38)
		last_touch_home = false
		_record_match_event("Opposition carries the ball")

func _opponent_tactical_target(index: int, press_index: int) -> Vector3:
	# One defender presses the ball carrier while nearby teammates cover passing lanes.
	if index == press_index:
		return ball.global_position
	var lane_z := clampf(ball.global_position.z * 0.55 + float(index - 5) * 2.2, -9.0, 9.0)
	var defensive_depth := 3.0 if ball.global_position.x > 4.0 else 5.0
	var target_x := maxf(-13.0, ball.global_position.x + defensive_depth)
	# Wide players protect the flanks; central players narrow the space around the ball.
	if index % 4 == 0:
		lane_z = -9.0
	elif index % 4 == 3:
		lane_z = 9.0
	return Vector3(target_x, 0.0, lane_z)

func _teammate_tactical_target(roster_index: int, role: String, formation_target: Vector3) -> Vector3:
	# Home attacks toward +X. When the home side has the ball, players create
	# staggered lanes; without it, the whole block shifts toward the ball.
	var target := formation_target
	var attacking := last_touch_home
	var ball_x := ball.global_position.x
	var ball_z := ball.global_position.z
	if not attacking:
		var compact_line := -7.0 if team_tactic != "Defensive" else -9.5
		target.x = minf(target.x, compact_line + clampf((ball_x + 10.0) * 0.16, -1.5, 2.0))
		target.z = lerpf(target.z, ball_z * 0.52 + target.z * 0.48, 0.28)
		return target
	if role == "Forward":
		var run_distance := 3.2
		if team_tactic == "Attacking":
			run_distance = 5.2
		elif team_tactic == "Defensive":
			run_distance = 1.4
		var lane_offset := -3.2 if roster_index % 2 == 0 else 3.2
		var desired_lane := clampf(ball_z * 0.58 + lane_offset, -8.0, 8.0)
		target.x = clampf(maxf(target.x + run_distance, ball_x + 3.0), -2.0, 14.5)
		target.z = lerpf(target.z, desired_lane, 0.62)
	elif role == "Midfielder":
		# Keep at least one short passing option behind the ball and one runner
		# close enough to support the attack around the penalty area.
		var support_depth := 3.8 if team_tactic != "Attacking" else 2.8
		if team_tactic == "Defensive":
			support_depth = 5.2
		target.x = clampf(ball_x - support_depth, -10.0, 8.0)
		var side := -2.8 if roster_index % 2 == 0 else 2.8
		target.z = clampf(ball_z * 0.48 + side, -8.0, 8.0)
	elif role == "Defender":
		var wide_fullback := roster_index == 0 or roster_index == 3
		var ball_is_wide := absf(ball_z) > 4.5
		if wide_fullback and ball_x > 1.0 and ball_is_wide and team_tactic == "Attacking":
			# The far-side full-back stays home; only the ball-side full-back overlaps.
			if signf(target.z) == signf(ball_z):
				target.x = clampf(ball_x - 1.5, -7.0, 9.0)
				target.z = clampf(ball_z * 1.12, -9.0, 9.0)
		else:
			var line := -7.0 if team_tactic != "Defensive" else -9.5
			target.x = minf(target.x, line + clampf(ball_x * 0.12, -1.0, 1.8))
	return target

func _goalkeeper_anticipation_target(defending_left: bool, threatening: bool, shot_approach: bool, anticipation: float) -> Vector3:
	var keeper_x := -FIELD_LENGTH / 2.0 + 1.0 if defending_left else FIELD_LENGTH / 2.0 - 1.0
	var target_z := 0.0
	if threatening:
		# Estimate where the ball will cross the keeper's line rather than following its current lane only.
		var travel_x := absf(keeper_x - ball.global_position.x)
		var velocity_x := absf(ball.linear_velocity.x)
		var time_to_line := clampf(travel_x / maxf(1.0, velocity_x), 0.0, 1.8) if shot_approach else 0.0
		var projected_z := ball.global_position.z + ball.linear_velocity.z * time_to_line
		target_z = clampf(projected_z * 0.68 + anticipation, -2.7, 2.7)
	return Vector3(keeper_x, 0.0, target_z)

func _calculate_player_performance_rating() -> float:
	var rating := 6.0
	rating += minf(1.5, float(match_stats.get("shots_on_target", 0)) * 0.3)
	rating += minf(1.0, float(match_stats.get("passes", 0)) * 0.08)
	rating += minf(1.0, float(match_stats.get("tackles", 0)) * 0.25)
	if score_home > score_away:
		rating += 0.8
	elif score_home < score_away:
		rating -= 0.8
	return clampf(rating, 1.0, 10.0)

func _calculate_team_performance_rating() -> float:
	var rating := 5.5
	if score_home > score_away:
		rating += 1.5
	elif score_home == score_away:
		rating += 0.4
	else:
		rating -= 1.0
	var possession_ticks := int(match_stats.get("possession_ticks", 0))
	var total_ticks := possession_ticks + int(match_stats.get("opponent_ticks", 0))
	var possession_ratio := float(possession_ticks) / maxf(1.0, float(total_ticks))
	rating += (possession_ratio - 0.5) * 2.0
	rating += minf(0.7, float(match_stats.get("passes", 0)) * 0.04)
	return clampf(rating, 1.0, 10.0)

func _animate_actor(actor: CharacterBody3D, moving: bool, delta: float) -> void:
	var actor_id := actor.get_instance_id()
	var visual := actor_visuals.get(actor_id) as MeshInstance3D
	if not is_instance_valid(visual):
		return
	var rig: Dictionary = actor_rigs.get(actor_id, {})
	var swing := sin(animation_clock * 12.5) * 0.58 if moving else 0.0
	var target_y := 0.9 + (absf(sin(animation_clock * 12.5)) * 0.075 if moving else 0.0)
	visual.position.y = lerpf(visual.position.y, target_y, minf(1.0, delta * 10.0))
	var target_tilt := clampf(-actor.velocity.x * 0.035, -0.18, 0.18) if moving else 0.0
	var dive_left := float(keeper_dive_time.get(actor_id, 0.0))
	if dive_left > 0.0:
		keeper_dive_time[actor_id] = maxf(0.0, dive_left - delta)
		target_tilt = -0.72 if actor.position.x < 0.0 else 0.72
	visual.rotation.z = lerpf(visual.rotation.z, target_tilt, minf(1.0, delta * (13.0 if dive_left > 0.0 else 7.0)))
	var left_leg := rig.get("left_leg") as MeshInstance3D
	var right_leg := rig.get("right_leg") as MeshInstance3D
	var left_arm := rig.get("left_arm") as MeshInstance3D
	var right_arm := rig.get("right_arm") as MeshInstance3D
	if is_instance_valid(left_leg) and is_instance_valid(right_leg):
		left_leg.rotation.x = lerpf(left_leg.rotation.x, swing, minf(1.0, delta * 12.0))
		right_leg.rotation.x = lerpf(right_leg.rotation.x, -swing, minf(1.0, delta * 12.0))
	if is_instance_valid(left_arm) and is_instance_valid(right_arm):
		var arm_swing := -swing * 0.48
		if dive_left <= 0.0:
			left_arm.rotation.x = lerpf(left_arm.rotation.x, arm_swing, minf(1.0, delta * 9.0))
			right_arm.rotation.x = lerpf(right_arm.rotation.x, -arm_swing, minf(1.0, delta * 9.0))

func _record_match_event(event_text: String) -> void:
	match_events.append("%02d:%02d %s" % [int(match_duration_seconds - seconds_left) / 60, int(match_duration_seconds - seconds_left) % 60, event_text])
	if match_events.size() > 12:
		match_events.pop_front()

func _award_free_kick(reason: String) -> void:
	foul_count += 1
	if reason == "late challenge":
		if red_cards_home > 0:
			_record_match_event("Referee warns the home side")
		else:
			yellow_cards_home += 1
			if yellow_cards_home >= 2:
				red_cards_home = 1
				player_sent_off = true
				_record_match_event("Second yellow — home player sent off")
			else:
				_record_match_event("Yellow card — home player")
	restart_for_home = true
	if player.position.x > FIELD_LENGTH / 2.0 - 8.0:
		restart_type = "Penalty"
		restart_position = Vector3(FIELD_LENGTH / 2.0 - 5.0, 0.35, 0.0)
	else:
		restart_type = "Free kick"
		restart_position = Vector3(clampf(player.position.x + 1.4, -FIELD_LENGTH / 2.0 + 3.0, FIELD_LENGTH / 2.0 - 3.0), 0.35, clampf(player.position.z, -FIELD_WIDTH / 2.0 + 2.0, FIELD_WIDTH / 2.0 - 2.0))
	ball.position = restart_position
	if restart_for_home:
		player.position = restart_position + Vector3(-1.5, 0.0, 0.0)
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball_reset_lock = 0.55
	_record_match_event(restart_type + " awarded: " + reason)
	status_label.text = "Foul! %s awarded. Cards: %dY %dR." % [restart_type, yellow_cards_home, red_cards_home]

func _handle_ball_out() -> void:
	if ball_reset_lock > 0.0 or restart_type != "None":
		return
	var pos := ball.global_position
	var half_l := FIELD_LENGTH * 0.5
	var half_w := FIELD_WIDTH * 0.5
	if absf(pos.z) > half_w + 0.35:
		restart_type = "Throw-in"
		restart_for_home = not last_touch_home
		restart_position = Vector3(clampf(pos.x, -half_l + 0.5, half_l - 0.5), 0.35, signf(pos.z) * (half_w - 0.15))
	elif absf(pos.x) > half_l + 0.35:
		var crossed_right := pos.x > 0.0
		if crossed_right:
			if last_touch_home:
				restart_type = "Goal kick"
				restart_for_home = false
			else:
				restart_type = "Corner"
				restart_for_home = true
		else:
			if last_touch_home:
				restart_type = "Corner"
				restart_for_home = false
			else:
				restart_type = "Goal kick"
				restart_for_home = true
		var corner_z := -half_w + 0.25 if pos.z < 0.0 else half_w - 0.25
		restart_position = Vector3(half_l - 0.35 if crossed_right else -half_l + 0.35, 0.35, corner_z) if restart_type == "Corner" else Vector3(half_l - 5.0 if crossed_right else -half_l + 5.0, 0.35, 0.0)
	else:
		return
	ball.position = restart_position
	if restart_for_home:
		player.position = restart_position + Vector3(-1.5, 0.0, 0.0)
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball_reset_lock = 0.6
	_record_match_event(restart_type + " awarded")
	status_label.text = "%s. %s restart — press FREE KICK." % [restart_type, "Your" if restart_for_home else "Opponent"]

func _check_offside() -> void:
	if pending_offside_actor_id == 0 or offside_check_cooldown > 0.0 or restart_type != "None":
		return
	var receiver: CharacterBody3D = null
	if player.get_instance_id() == pending_offside_actor_id:
		receiver = player
	else:
		for mate in teammates:
			if mate.get_instance_id() == pending_offside_actor_id:
				receiver = mate
				break
	if receiver == null:
		pending_offside_actor_id = 0
		return
	if receiver.global_position.distance_to(ball.global_position) <= 1.45:
		restart_type = "Indirect free kick"
		restart_for_home = false
		restart_position = Vector3(clampf(pending_offside_position.x, -FIELD_LENGTH / 2.0 + 2.0, FIELD_LENGTH / 2.0 - 2.0), 0.35, clampf(pending_offside_position.z, -FIELD_WIDTH / 2.0 + 1.0, FIELD_WIDTH / 2.0 - 1.0))
		ball.position = restart_position
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		ball_reset_lock = 0.6
		offside_check_cooldown = 1.0
		pending_offside_actor_id = 0
		_record_match_event("Offside — opposition indirect free kick")
		status_label.text = "Offside! Opposition awarded an indirect free kick."

func _check_goal() -> void:
	if ball_reset_lock > 0.0:
		return
	var pos := ball.global_position
	if absf(pos.z) <= GOAL_HALF_WIDTH - 0.12 and pos.y <= GOAL_HEIGHT - 0.12:
		if pos.x > FIELD_LENGTH / 2.0 + 0.25:
			score_home += 1
			status_label.text = "%s scores!" % str(career.get("club", "Nairobi United"))
			_record_match_event(str(career.get("club", "Nairobi United")) + " goal")
			_reset_after_goal()
		elif pos.x < -FIELD_LENGTH / 2.0 - 0.25:
			score_away += 1
			status_label.text = "%s scores!" % current_opponent_name
			_record_match_event("%s goal" % current_opponent_name)
			_reset_after_goal()

func _reset_after_goal() -> void:
	ball.position = Vector3(0, 0.35, 0)
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	player.position = Vector3(-7.0, 0, 0)
	for i in range(teammates.size()):
		var slot := i if i < controlled_squad_index else i + 1
		teammates[i].position = _formation_position(slot)
	goalkeepers[0].position = Vector3(-FIELD_LENGTH / 2.0 + 1.0, 0, 0)
	goalkeepers[1].position = Vector3(FIELD_LENGTH / 2.0 - 1.0, 0, 0)
	ball_reset_lock = 1.0
	if is_instance_valid(hud):
		hud.text = "%s  %d - %d  %s   |   %02d:%02d   |   %s" % [str(career.get("club", "Nairobi United")), score_home, score_away, current_opponent_name, int(seconds_left) / 60, int(seconds_left) % 60, formation_name]

func _formation_position(index: int) -> Vector3:
	# index 0..9 maps the ten outfield teammates; the controlled player is
	# positioned centrally among the forwards at the start of a match.
	var z := 0.0
	var x := -7.0
	if formation_name == "4-4-2":
		if index < 4:
			x = -10.0
			z = [-8.0, -3.0, 3.0, 8.0][index]
		elif index < 8:
			x = -3.5
			z = [-8.0, -3.0, 3.0, 8.0][index - 4]
		else:
			x = 4.0
			z = -3.0 if index == 8 else 3.0
	else:
		if index < 4:
			x = -10.0
			z = [-8.0, -3.0, 3.0, 8.0][index]
		elif index < 7:
			x = -3.0
			z = [-6.0, 0.0, 6.0][index - 4]
		else:
			x = 4.0
			z = [-6.0, 0.0, 6.0][index - 7]
	return Vector3(x, 0, z)

func _opponent_formation_position(index: int) -> Vector3:
	var base := _formation_position(index)
	return Vector3(-base.x, 0, base.z)

func _get_starting_lineup() -> Array:
	# Goalkeepers are represented by dedicated in-match keeper actors.
	# Injured/suspended players are skipped; eligible reserves fill vacancies.
	var starters: Array = []
	for member in squad_roster:
		_ensure_player_condition(member)
		if str(member.get("position", "Midfielder")) != "Goalkeeper" and str(member.get("role", "Reserve")) == "Starter" and _player_available(member):
			starters.append(member)
	for member in squad_roster:
		if starters.size() >= 10:
			break
		if str(member.get("position", "Midfielder")) != "Goalkeeper" and not starters.has(member) and _player_available(member):
			starters.append(member)
	return starters

func _find_controlled_lineup_index() -> int:
	for i in range(active_lineup.size()):
		if str(active_lineup[i].get("position", "")) == "Forward":
			return i
	return 0

func _lineup_position(index: int) -> String:
	if index >= 0 and index < active_lineup.size():
		return str(active_lineup[index].get("position", "Midfielder"))
	return "Midfielder"

func _lineup_rating(index: int) -> int:
	if index >= 0 and index < active_lineup.size():
		return int(active_lineup[index].get("rating", 60))
	return 60

func _cycle_formation() -> void:
	formation_name = "4-4-2" if formation_name == "4-3-3" else "4-3-3"
	_show_career()

func _cycle_team_tactic() -> void:
	if team_tactic == "Balanced":
		team_tactic = "Attacking"
	elif team_tactic == "Attacking":
		team_tactic = "Defensive"
	else:
		team_tactic = "Balanced"
	_save_career()
	_show_career()

func _switch_player() -> void:
	if not match_running or switch_cooldown > 0.0:
		return
	var best_index := -1
	var best_distance := INF
	for i in range(teammates.size()):
		var distance := teammates[i].global_position.distance_to(ball.global_position)
		if distance < best_distance:
			best_distance = distance
			best_index = i
	if best_index >= 0:
		var previous_player := player
		player = teammates[best_index]
		teammates[best_index] = previous_player
		var previous_index := controlled_squad_index
		controlled_squad_index = best_index if best_index < previous_index else best_index + 1
		switch_cooldown = 0.65
		var selected_name := str(active_lineup[controlled_squad_index].get("name", "Player")) if controlled_squad_index < active_lineup.size() else "Player"
		status_label.text = "Now controlling %s." % selected_name

func _stamina_for(actor: CharacterBody3D) -> float:
	return float(actor_stamina.get(actor.get_instance_id(), 100.0))

func _set_stamina(actor: CharacterBody3D, value: float) -> void:
	actor_stamina[actor.get_instance_id()] = clampf(value, 0.0, 100.0)

func _set_move(direction: Vector2) -> void:
	move_vector = direction

func _release_move(direction: Vector2) -> void:
	if move_vector == direction:
		move_vector = Vector2.ZERO

func _make_hold_button(caption: String, direction: Vector2) -> Button:
	var button := _make_button(caption, func(): pass)
	button.button_down.connect(func(): _set_move(direction))
	button.button_up.connect(func(): _release_move(direction))
	return button

func _shoot() -> void:
	if not match_running:
		return
	if player.global_position.distance_to(ball.global_position) <= 2.4:
		var goal_target := Vector3(FIELD_LENGTH / 2.0 + 1.0, 1.0, clampf(-ball.global_position.z * 0.16, -1.7, 1.7))
		if restart_type == "Penalty":
			goal_target = Vector3(FIELD_LENGTH / 2.0 + 1.0, 1.25, clampf(ball.global_position.z * -0.12, -1.9, 1.9))
		var direction := goal_target - ball.global_position
		direction.y += 0.16
		var shooting_rating := _lineup_rating(controlled_squad_index)
		var shot_power := 7.5 + float(shooting_rating) * 0.035 + float(player_attributes.shooting) * 0.01
		if ball.global_position.x > 9.0:
			shot_power *= 0.88
		ball.apply_central_impulse(direction.normalized() * shot_power)
		last_touch_home = true
		pending_offside_actor_id = 0
		restart_type = "None"
		match_stats.shots = int(match_stats.shots) + 1
		var projected_goal_z := ball.global_position.z + direction.normalized().z * 8.0
		if absf(projected_goal_z) <= GOAL_HALF_WIDTH:
			match_stats.shots_on_target = int(match_stats.get("shots_on_target", 0)) + 1
			_record_match_event(str(career.get("club", "Nairobi United")) + " shot on target")
		else:
			_record_match_event(str(career.get("club", "Nairobi United")) + " shot")
		status_label.text = "Shot taken!"
	else:
		status_label.text = "Move closer to the ball first."

func _pass_ball() -> void:
	if not match_running:
		return
	if player.global_position.distance_to(ball.global_position) > 2.6:
		status_label.text = "Get close to the ball before passing."
		return
	var best_mate: CharacterBody3D = null
	var best_score := -INF
	for mate in teammates:
		var separation := player.global_position.distance_to(mate.global_position)
		if separation < 1.8 or separation > 15.0:
			continue
		var forward_space := mate.global_position.x - player.global_position.x
		var lane_space := 1.0 - minf(1.0, absf(mate.global_position.z) / (FIELD_WIDTH * 0.5))
		var score := forward_space * 0.42 + lane_space * 1.6 - separation * 0.12
		if score > best_score:
			best_score = score
			best_mate = mate
	if best_mate != null:
		# Offside position is judged when the pass is played, using the second-last
		# opponent (including the opposing goalkeeper) and the ball position.
		var opponent_line: Array[float] = []
		for defender in opponents:
			opponent_line.append(defender.global_position.x)
		opponent_line.append(goalkeepers[1].global_position.x)
		opponent_line.sort()
		var second_last_defender_x := opponent_line[maxi(0, opponent_line.size() - 2)]
		var receiver_x := best_mate.global_position.x
		if receiver_x > 0.0 and receiver_x > ball.global_position.x and receiver_x > second_last_defender_x:
			pending_offside_actor_id = best_mate.get_instance_id()
			pending_offside_position = best_mate.global_position
		else:
			pending_offside_actor_id = 0
		var lead_position := best_mate.global_position + best_mate.velocity * 0.32
		var pass_direction := lead_position - ball.global_position
		pass_direction.y = 0.12
		var passing_rating := _lineup_rating(controlled_squad_index)
		ball.apply_central_impulse(pass_direction.normalized() * (4.5 + float(passing_rating) * 0.02 + float(player_attributes.passing) * 0.01))
		last_touch_home = true
		restart_type = "None"
		match_stats.passes = int(match_stats.passes) + 1
		_record_match_event("Pass completed")
		status_label.text = "Pass played into a teammate's path."

func _make_substitution() -> void:
	if not match_running:
		return
	if substitutions_used >= 3:
		status_label.text = "All three substitutions have been used."
		return
	if teammates.is_empty():
		return
	var outgoing_index := substitutions_used % teammates.size()
	var lineup_index := outgoing_index if outgoing_index < controlled_squad_index else outgoing_index + 1
	if lineup_index < 0 or lineup_index >= active_lineup.size():
		status_label.text = "No eligible player is available to replace."
		return
	var outgoing_data: Dictionary = active_lineup[lineup_index]
	var outgoing_position := str(outgoing_data.get("position", "Midfielder"))
	var reserve_index := -1
	for i in range(squad_roster.size()):
		var candidate: Dictionary = squad_roster[i]
		if str(candidate.get("role", "Reserve")) == "Reserve" and str(candidate.get("position", "Midfielder")) == outgoing_position and _player_available(candidate):
			reserve_index = i
			break
	if reserve_index == -1:
		for i in range(squad_roster.size()):
			var candidate: Dictionary = squad_roster[i]
			if str(candidate.get("role", "Reserve")) == "Reserve" and str(candidate.get("position", "")) != "Goalkeeper" and _player_available(candidate):
				reserve_index = i
				break
	if reserve_index == -1:
		status_label.text = "No reserve outfield player is available."
		return
	var incoming: Dictionary = squad_roster[reserve_index]
	var outgoing_roster_index := squad_roster.find(outgoing_data)
	if outgoing_roster_index >= 0:
		squad_roster[outgoing_roster_index]["role"] = "Reserve"
	incoming["role"] = "Starter"
	active_lineup[lineup_index] = incoming.duplicate(true)
	var old_actor := teammates[outgoing_index]
	var new_actor := _make_player(Color(0.2, 0.75, 1.0), old_actor.position)
	new_actor.name = str(incoming.get("name", "Substitute"))
	add_child(new_actor)
	old_actor.queue_free()
	teammates[outgoing_index] = new_actor
	actor_stamina.erase(old_actor.get_instance_id())
	actor_visuals.erase(old_actor.get_instance_id())
	actor_stamina[new_actor.get_instance_id()] = 100.0
	substitutions_used += 1
	_save_career()
	status_label.text = "%s replaces %s (%d/3)." % [incoming.get("name", "Substitute"), outgoing_data.get("name", "Player"), substitutions_used]

func _take_free_kick() -> void:
	if not match_running:
		return
	if restart_type == "None":
		restart_type = "Free kick"
		restart_for_home = true
		restart_position = Vector3(clampf(player.position.x + 2.0, -FIELD_LENGTH / 2.0 + 4.0, FIELD_LENGTH / 2.0 - 4.0), 0.35, clampf(player.position.z, -FIELD_WIDTH / 2.0 + 2.0, FIELD_WIDTH / 2.0 - 2.0))
	ball.position = restart_position
	if restart_for_home:
		player.position = restart_position + Vector3(-1.5, 0.0, 0.0)
	else:
		var opponent_restart_direction := Vector3(-1.0, 0.12, 0.0)
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		ball.apply_central_impulse(opponent_restart_direction * 4.0)
		last_touch_home = false
		restart_type = "None"
		ball_reset_lock = 0.35
		status_label.text = "Opposition takes the indirect free kick."
		return
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball_reset_lock = 0.35
	status_label.text = "%s set. Press SHOOT to take it." % restart_type

func _tackle() -> void:
	if not match_running or tackle_cooldown > 0.0:
		return
	var nearest_enemy: CharacterBody3D = null
	var nearest_distance := INF
	for enemy in opponents:
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	if nearest_enemy != null and nearest_distance <= 2.1:
		if nearest_distance < 1.05 and randf() < 0.22:
			tackle_cooldown = 1.0
			_award_free_kick("late challenge")
			return
		var steal_direction := player.global_position - nearest_enemy.global_position
		steal_direction.y = 0.16
		if steal_direction.length() < 0.1:
			steal_direction = Vector3.LEFT
		ball.apply_central_impulse(steal_direction.normalized() * 4.2)
		last_touch_home = true
		nearest_enemy.velocity = Vector3.ZERO
		match_stats.tackles = int(match_stats.tackles) + 1
		_record_match_event("Successful tackle")
		tackle_cooldown = 1.0
		status_label.text = "Successful challenge! Win the ball."
	else:
		status_label.text = "Move closer to an opponent to challenge."

func _finish_match(is_career: bool) -> void:
	if not match_running:
		return
	match_running = false
	get_tree().paused = false
	match_paused = false
	if is_instance_valid(pause_overlay):
		pause_overlay.queue_free()
	if is_instance_valid(match_timer):
		match_timer.queue_free()
	if is_career:
		career.played = int(career.played) + 1
		if score_home > score_away:
			career.wins = int(career.wins) + 1
			career.points = int(career.points) + 3
			career.cash = int(career.cash) + 25000
		elif score_home == score_away:
			career.points = int(career.points) + 1
			career.cash = int(career.cash) + 10000
		else:
			career.cash = int(career.cash) + 5000
		if score_home > score_away:
			league_table[str(career.get("club", "Nairobi United"))] = int(league_table.get(str(career.get("club", "Nairobi United")), 0)) + 3
		elif score_home == score_away:
			league_table[str(career.get("club", "Nairobi United"))] = int(league_table.get(str(career.get("club", "Nairobi United")), 0)) + 1
			league_table[current_opponent_name] = int(league_table.get(current_opponent_name, 0)) + 1
		else:
			league_table[current_opponent_name] = int(league_table.get(current_opponent_name, 0)) + 3
		_update_league_record(str(career.get("club", "Nairobi United")), score_home, score_away)
		_update_league_record(current_opponent_name, score_away, score_home)
		_process_squad_after_match()
		var club_name := str(career.get("club", "Nairobi United"))
		var fixture_home_name := club_name if current_fixture_home else current_opponent_name
		var fixture_away_name := current_opponent_name if current_fixture_home else club_name
		var fixture_home_score := score_home if current_fixture_home else score_away
		var fixture_away_score := score_away if current_fixture_home else score_home
		var other_fixture := _simulate_other_league_fixture(fixture_index)
		fixture_results.append({
			"round": fixture_index + 1,
			"home": fixture_home_name,
			"away": fixture_away_name,
			"score": "%d-%d" % [fixture_home_score, fixture_away_score],
			"club_home": current_fixture_home,
			"other_fixture": other_fixture
		})
		fixture_index += 1
		if fixture_index >= 6:
			_archive_completed_season()
			career.season = int(career.season) + 1
			career.played = 0
			career.points = 0
			fixture_index = 0
			fixture_results.clear()
			league_table = {club_name: 0, "Red City": 0, "Coastal Rovers": 0, "Highland FC": 0}
			league_records.clear()
		_save_career()
	_show_result(is_career)

func _show_result(is_career: bool) -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("FULL TIME", 34))
	panel.add_child(_label("%s  %d - %d  %s" % [str(career.get("club", "Nairobi United")), score_home, score_away, current_opponent_name], 25))
	panel.add_child(_label("Career progress saved on this device." if is_career else "Exhibition match completed.", 17))
	last_player_rating = _calculate_player_performance_rating()
	last_team_rating = _calculate_team_performance_rating()
	panel.add_child(_label("PERFORMANCE RATINGS", 22))
	panel.add_child(_label("Controlled player: %.1f / 10    Team: %.1f / 10" % [last_player_rating, last_team_rating], 18))
	var total_ticks := int(match_stats.possession_ticks) + int(match_stats.opponent_ticks)
	var possession := int(float(match_stats.possession_ticks) * 100.0 / maxf(1.0, float(total_ticks)))
	panel.add_child(_label("MATCH STATISTICS", 23))
	panel.add_child(_label("Shots: %s (%s on target)   Saves: %s" % [match_stats.shots, match_stats.get("shots_on_target", 0), match_stats.get("saves", 0)], 17))
	panel.add_child(_label("Passes: %s   Tackles: %s" % [match_stats.passes, match_stats.tackles], 17))
	panel.add_child(_label("Estimated possession: %d%% - %d%%" % [possession, 100 - possession], 17))
	panel.add_child(_label("Fouls: %d   Substitutions: %d/3" % [foul_count, substitutions_used], 16))
	var recent_events := ""
	for event_text in match_events.slice(maxi(0, match_events.size() - 5)):
		recent_events += (" | " if not recent_events.is_empty() else "") + event_text
	if recent_events.is_empty():
		recent_events = "No major events recorded"
	panel.add_child(_label("Recent events: " + recent_events, 13))
	panel.add_child(_make_button("FULL MATCH COMMENTARY", _show_match_commentary))
	panel.add_child(_make_button("CONTINUE", _show_menu))

func _show_match_commentary() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("MATCH COMMENTARY", 30))
	if match_events.is_empty():
		panel.add_child(_label("No major events were recorded.", 17))
	else:
		for event_text in match_events:
			panel.add_child(_label(event_text, 15))
	panel.add_child(_make_button("BACK TO FULL-TIME REPORT", func(): _show_result(current_match_is_career)))

func _reset_career() -> void:
	career = {"club": "Nairobi United", "season": 1, "played": 0, "wins": 0, "points": 0, "cash": 250000}
	squad_rating = 62
	player_attributes = {"pace": 62, "passing": 60, "shooting": 61, "defending": 58, "goalkeeping": 55}
	league_table = {str(career.get("club", "Nairobi United")): 0, "Red City": 0, "Coastal Rovers": 0, "Highland FC": 0}
	league_records = {}
	fixture_index = 0
	fixture_results = []
	season_history = []
	difficulty_name = "Normal"
	difficulty_speed_factor = 1.0
	match_duration_minutes = 5
	club_palette_index = 0
	selected_club_preset = 0
	team_tactic = "Balanced"
	training_focus = "Balanced"
	_ensure_squad(true)
	_save_career()
	_show_menu()

func _save_career() -> void:
	career["squad_rating"] = squad_rating
	career["player_attributes"] = player_attributes
	career["league_table"] = league_table
	career["league_records"] = league_records
	career["formation"] = formation_name
	career["team_tactic"] = team_tactic
	career["training_focus"] = training_focus
	career["fixture_index"] = fixture_index
	career["squad_roster"] = squad_roster
	career["fixture_results"] = fixture_results
	career["season_history"] = season_history
	career["transfer_market"] = transfer_market
	career["difficulty"] = difficulty_name
	career["match_duration_minutes"] = match_duration_minutes
	career["kit_colour_index"] = club_palette_index
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(career))

func _load_career() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			career = parsed
			squad_rating = int(career.get("squad_rating", 62))
			player_attributes = career.get("player_attributes", player_attributes)
			league_table = career.get("league_table", league_table)
			league_records = career.get("league_records", {})
			formation_name = str(career.get("formation", "4-3-3"))
			team_tactic = str(career.get("team_tactic", "Balanced"))
			training_focus = str(career.get("training_focus", "Balanced"))
			if not TRAINING_FOCUSES.has(training_focus):
				training_focus = "Balanced"
			fixture_index = int(career.get("fixture_index", 0))
			squad_roster = career.get("squad_roster", [])
			fixture_results = career.get("fixture_results", [])
			season_history = career.get("season_history", [])
			transfer_market = career.get("transfer_market", transfer_market)
			difficulty_name = str(career.get("difficulty", "Normal"))
			match_duration_minutes = int(career.get("match_duration_minutes", 5))
		club_palette_index = clampi(int(career.get("kit_colour_index", 0)), 0, CLUB_COLORS.size() - 1)
		for i in range(CLUB_PRESETS.size()):
			if CLUB_PRESETS[i] == str(career.get("club", "Nairobi United")):
				selected_club_preset = i
			if difficulty_name == "Easy":
				difficulty_speed_factor = 0.82
			elif difficulty_name == "Hard":
				difficulty_speed_factor = 1.18
			else:
				difficulty_speed_factor = 1.0

func _ensure_squad(reset: bool = false) -> void:
	if reset or squad_roster.is_empty():
		squad_roster = [
			{"name": "Alex Maina", "position": "Goalkeeper", "rating": 62, "role": "Starter"},
			{"name": "John Ochieng", "position": "Defender", "rating": 61, "role": "Starter"},
			{"name": "Mark Otieno", "position": "Defender", "rating": 60, "role": "Starter"},
			{"name": "Kevin Barasa", "position": "Defender", "rating": 59, "role": "Starter"},
			{"name": "David Kibet", "position": "Defender", "rating": 60, "role": "Starter"},
			{"name": "Eric Omondi", "position": "Midfielder", "rating": 63, "role": "Starter"},
			{"name": "Felix Njoroge", "position": "Midfielder", "rating": 61, "role": "Starter"},
			{"name": "Moses Wanjala", "position": "Midfielder", "rating": 60, "role": "Starter"},
			{"name": "Isaac Auma", "position": "Forward", "rating": 64, "role": "Starter"},
			{"name": "Caleb Mutua", "position": "Forward", "rating": 62, "role": "Starter"},
			{"name": "Noah Kipchoge", "position": "Forward", "rating": 61, "role": "Starter"},
			{"name": "Victor Odhiambo", "position": "Midfielder", "rating": 57, "role": "Reserve"},
			{"name": "Paul Were", "position": "Defender", "rating": 56, "role": "Reserve"},
			{"name": "Simon Kariuki", "position": "Forward", "rating": 58, "role": "Reserve"}
		]
	for member in squad_roster:
		_ensure_player_condition(member)

func _show_squad() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("SQUAD & PLAYER ROLES", 30))
	panel.add_child(_label("Select a player to switch between Starter and Reserve", 15))
	for index in range(squad_roster.size()):
		var member: Dictionary = squad_roster[index]
		_ensure_player_condition(member)
		var availability := "Available" if _player_available(member) else "Injured: %d / Suspended: %d" % [member.injury_matches, member.suspension_matches]
		var caption := "%s  |  %s  |  %d OVR  |  %s  |  Fitness %d%%  |  %s" % [member.name, member.position, member.rating, member.role, member.fitness, availability]
		panel.add_child(_make_button(caption, func(): _toggle_squad_role(index)))
	panel.add_child(_make_button("BACK TO CLUB", _show_career))

func _toggle_squad_role(index: int) -> void:
	if index < 0 or index >= squad_roster.size():
		return
	var member: Dictionary = squad_roster[index]
	var starter_count := 0
	for item in squad_roster:
		if str(item.role) == "Starter":
			starter_count += 1
	if str(member.role) == "Starter":
		member.role = "Reserve"
	else:
		if starter_count >= 11:
			member.role = "Reserve"
			_show_squad()
			return
		member.role = "Starter"
	_save_career()
	_show_squad()

func _show_transfer_market() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("TRANSFER MARKET", 30))
	panel.add_child(_label("Available funds: KSh %s" % career.cash, 19))
	for index in range(transfer_market.size()):
		var offer: Dictionary = transfer_market[index]
		var description := "%s | %s | %d OVR | KSh %d" % [offer.name, offer.position, offer.rating, offer.price]
		panel.add_child(_make_button("SIGN: " + description, func(): _sign_player(index)))
	panel.add_child(_make_button("BACK TO CLUB", _show_career))

func _sign_player(index: int) -> void:
	if index < 0 or index >= transfer_market.size():
		return
	var offer: Dictionary = transfer_market[index]
	if int(career.cash) < int(offer.price):
		_show_transfer_market()
		return
	career.cash = int(career.cash) - int(offer.price)
	var new_player := {"name": offer.name, "position": offer.position, "rating": offer.rating, "role": "Reserve"}
	squad_roster.append(new_player)
	transfer_market.remove_at(index)
	_save_career()
	_show_transfer_market()

func _show_fixtures() -> void:
	_clear_ui()
	var panel := _panel()
	panel.add_child(_label("FIXTURES & RESULTS", 30))
	for index in range(6):
		var fixture_text := "Round %d: %s" % [index + 1, _fixture_description(index)]
		if index < fixture_results.size():
			fixture_text += "  |  %s" % fixture_results[index].get("score", "Played")
		elif index == fixture_index:
			fixture_text += "  |  NEXT"
		else:
			fixture_text += "  |  Upcoming"
		panel.add_child(_label(fixture_text, 17))
		if index < fixture_results.size():
			var other: Dictionary = fixture_results[index].get("other_fixture", {})
			if not other.is_empty():
				panel.add_child(_label("Other match: %s vs %s  |  %s" % [other.get("home", ""), other.get("away", ""), other.get("score", "")], 13))
	panel.add_child(_label("SEASON HONOURS", 22))
	if season_history.is_empty():
		panel.add_child(_label("No completed seasons yet.", 14))
	else:
		for history in season_history.slice(maxi(0, season_history.size() - 5), season_history.size()):
			panel.add_child(_label("Season %s champions: %s  |  Runner-up: %s" % [history.get("season", "?"), history.get("champion", ""), history.get("runner_up", "")], 14))
	panel.add_child(_make_button("BACK TO CLUB", _show_career))

func _panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.anchor_left = 0.05
	panel.anchor_right = 0.95
	panel.anchor_top = 0.04
	panel.anchor_bottom = 0.96
	panel.add_theme_constant_override("separation", 12)
	screen_root.add_child(panel)
	return panel

func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _make_button(caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(160, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	return button
