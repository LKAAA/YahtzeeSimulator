extends Node3D

@onready var yahtzee_checker: YahtzeeChecker = %YahtzeeChecker
@onready var text_label: RichTextLabel = %TextLabel
@onready var cam: Camera3D = %Camera3D

const RAY_LENGTH = 10000.0

var selected_dice: Array[DieObject] = []

var dice: Array[DieObject] = []
var die_spawns: Array[Node3D] = []

var roll_count: int = 0
var ending_turn: bool = false

func _ready() -> void:
	get_dice()
	get_spawns()

func get_dice() -> void:
	for object in get_children():
		if object is DieObject:
			dice.append(object)

func get_spawns() -> void:
	for object in get_children():
		if object.is_in_group("Spawnpoint"):
			die_spawns.append(object)

func _process(delta: float) -> void:
	if roll_count == 3:
		if not check_rolling() and not ending_turn:
			done_rolling()
	
	if check_if_all_locked():
		reset_board()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Roll Dice") and not ending_turn:
		if not check_rolling(): # Nothing currently rolling
			text_label.visible = false
			roll_dice(selected_dice)
	
	if event.is_action_pressed("Click") and not ending_turn:
		var clicked_dice: DieObject = get_click()
		if clicked_dice and not clicked_dice.locked:
			select_die(clicked_dice)
	
	if event.is_action_pressed("Lock") and not ending_turn:
		var clicked_dice: DieObject = get_click()
		if clicked_dice: 
			lock_die(clicked_dice)
	
	if event.is_action_pressed("Select All") and not ending_turn:
		for die in dice:
			select_die(die)

func get_click() -> DieObject:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if result:
		var collision_object = result.collider
		if collision_object is DieObject:
			return collision_object
	return null

func roll_dice(selected_dce: Array[DieObject]) -> void:
	for die in selected_dce:
		do_pick_up(die)
		die.unselect()
	roll_count += 1
	selected_dice.clear()

func select_die(die: DieObject) -> void:
	if die.selected:
		die.unselect()
		selected_dice.remove_at(selected_dice.find(die))
	else:
		die.select()
		selected_dice.append(die)

func lock_die(die: DieObject) -> void:
	if die.locked:
		die.unlock()
	else:
		if die.selected:
			selected_dice.remove_at(selected_dice.find(die))
		die.lock()

func check_if_all_locked() -> bool:
	var tick = 0
	for die in dice:
		if die.locked:
			tick += 1
	
	if tick == 5:
		return true
	else:
		return false

func check_rolling() -> bool:
	for die in dice:
		if die.rolling:
			return true
	return false

func check_roll_count() -> bool:
	if roll_count == 3:
		return true
	return false

func do_pick_up(die: DieObject) -> void:
	die.apply_impulse(Vector3.UP * 8+ generate_random_direction() * 2)
	die.apply_torque_impulse(Vector3(generate_random_rotation(-3, 3, false), generate_random_rotation(-3, 3, false), generate_random_rotation(-3, 3, false)))
	await get_tree().create_timer(0.1).timeout
	die.rolling = true

func generate_random_direction() -> Vector3:
	var ran_num = randi_range(0, 3)
	match ran_num:
		0:
			return Vector3(1, 0, 0)
		1:
			return Vector3(-1, 0, 0)
		2:
			return Vector3(0, 0, -1)
		3:
			return Vector3(0, 0, 1)
		_:
			return Vector3(0, 0, -1)


func generate_random_rotation(min: int = 0, max: int = 1, can_be_zero: bool = true) -> int:
	var ran_num = randi_range(min, max)
	if not can_be_zero:
		while ran_num == 0 or ran_num == 1 or ran_num == -1:
			ran_num = randi_range(min, max)
	
	return ran_num

func done_rolling() -> void:
	ending_turn = true
	await get_tree().create_timer(4).timeout
	reset_board()

func reset_board() -> void:
	check_what_have()
	var ticker = 0
	for die in dice:
		die.reset()
		die.position = die_spawns[ticker].position
		ticker += 1
		select_die(die)
	
	roll_count = 0
	ending_turn = false

func check_what_have() -> void:
	yahtzee_parser(yahtzee_checker.check_what_have(dice))

func yahtzee_parser(input: Array[int]) -> void:
	var output: String = ""
	for i in input.size():
		match i:
			0: output += "Aces: %d\n" %input[i]
			1: output += "Twos: %d\n" %input[i]
			2: output += "Threes: %d\n" %input[i]
			3: output += "Fours: %d\n" %input[i]
			4: output += "Fives: %d\n" %input[i]
			5: output += "Sixes: %d\n" %input[i]
			6: output += "3 of a kind: %d\n" %input[i]
			7: output += "4 of a kind: %d\n" %input[i]
			8: output += "Full House: %d\n" %input[i]
			9: output += "Sm Straight: %d\n" %input[i]
			10: output += "Lg Straight: %d\n" %input[i]
			11: output += "YAHTZEE: %d\n" %input[i]
			12: output += "Chance: %d\n" %input[i]
	print(output)
	text_label.text = output
	text_label.visible = true
