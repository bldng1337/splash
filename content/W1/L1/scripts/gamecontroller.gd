extends Node2D

var pipe_straight = preload("res://assets/W1L1/pipe_straight.png")
var pipe_corner = preload("res://assets/W1L1/pipe_corner.png")
var pipe_triple = preload("res://assets/W1L1/pipe_triple.png")
var pipe_cross = preload("res://assets/W1L1/Pipe_cross.png")
var pipe_end = preload("res://assets/W1L1/pipe_endstart.png")

var grid_size: Vector2i = Vector2i(10, 5)
var cell_size: float = 120.0
var grid_offset: Vector2 = Vector2.ZERO

var cells: Array[Array] = []
var pipes: Array[Vector2i] = []

var game_complete: bool = false

func _ready() -> void:
	manager.register_objective()
	calculate_grid_offset()
	generate_path()
	spawn_pipes()

func calculate_grid_offset() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	grid_offset.x = (viewport_size.x - grid_size.x * cell_size) / 2 + cell_size / 2
	grid_offset.y = (viewport_size.y - grid_size.y * cell_size) / 2 + cell_size / 2

var dirs = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

func random_dir() -> Vector2i:
	return dirs[randi() % dirs.size()]

var visited: Array[Vector2i] = []

var branch_chance = 0.4
var correct_rotation_chance = 0.2

func generate_path() -> void:
	# Initialize cells grid
	for i in range(grid_size.x):
		cells.append([])
		for j in range(grid_size.y):
			cells[i].append(false)

	var pos_stack: Array[Vector2i] = [Vector2i(grid_size.x/2, grid_size.y / 2)]#randi() %
	var dir_stack: Array[Vector2i] = [Vector2i(1, 0)]


	for steps in range(manager.get_difficulty()*15+5):
		if pos_stack.size() < 0:
			break
		var cell = pos_stack.pop_back()
		var dir = dir_stack.pop_back()
		if cell == null:
			break
		# Check bounds
		if cell.x < 0 or cell.x >= grid_size.x or cell.y < 0 or cell.y >= grid_size.y:
			continue

		# Check if already visited
		if cells[cell.x][cell.y]:
			continue

		# Mark as visited and add to pipes
		cells[cell.x][cell.y] = true
		pipes.append(cell)
		visited.append(cell)

		# Choose next direction - prefer continuing in same direction
		var first = dir if randf() > 0.5 else random_dir()
		if steps<3:
			if cell.x <= 0 or cell.x >= grid_size.x-1 or cell.y <= 0 or cell.y >= grid_size.y-1:
				for nextdir in dirs:
					if cells[cell.x+nextdir.x][cell.y+nextdir.y]==false:
						first=nextdir
						break
			if cell.x == 0:
				first = Vector2i(1, 0)
			if cell.x == grid_size.x-1:
				first = Vector2i(-1, 0)
			if cell.y == 0:
				first = Vector2i(0, 1)
			if cell.y == grid_size.y-1:
				first = Vector2i(0, -1)

		pos_stack.append(cell + first)
		dir_stack.append(first)

		# Chance to branch
		if randf() < branch_chance:
			var second = random_dir()
			for _i in range(100):
				if second != first:
					break
				second = random_dir()
			pos_stack.append(cell + second)
			dir_stack.append(second)

var correct_pipe_rotations: Array[Array] = []
var pipe_rotations: Array[int] = []
var pipe_sprites: Array[Sprite2D] = []
var pipe_types: Array[String] = []

func spawn_pipes() -> void:
	for pipe in pipes:
		var needed_dirs: Array[Vector2i] = []
		for dir in dirs:
			var neighbor = pipe + dir
			if neighbor.x < 0 or neighbor.x >= grid_size.x or neighbor.y < 0 or neighbor.y >= grid_size.y:
				continue
			if cells[neighbor.x][neighbor.y]:
				needed_dirs.append(dir)

		var pipe_type = choose_pipe_type(needed_dirs)
		var correct_rotation = find_correct_rotations(pipe_type, needed_dirs)
		var rotation = correct_rotation[0]

		# Randomize rotation with a chance
		if randf() < correct_rotation_chance:
			for _i in range(100):
				if rotation not in correct_rotation:
					break
				rotation = randi() % 4

		var pipe_sprite = Sprite2D.new()
		pipe_sprite.texture = get_pipe_texture(pipe_type)
		pipe_sprite.scale = Vector2(0.125, 0.125)
		pipe_sprite.position = Vector2(pipe.x * cell_size, pipe.y * cell_size) + grid_offset
		pipe_sprite.rotation_degrees = rotation * 90
		add_child(pipe_sprite)

		pipe_types.append(pipe_type)
		pipe_rotations.append(rotation)
		correct_pipe_rotations.append(correct_rotation)
		pipe_sprites.append(pipe_sprite)

	var wrong_pipe_idx= randi()%pipes.size()
	for _i in range(100):
		if pipe_types[wrong_pipe_idx]!="cross":
			break
		wrong_pipe_idx= randi()%pipes.size()

	# Ensure at least one pipe is incorrect
	for _i in range(100):
		if pipe_rotations[wrong_pipe_idx] not in correct_pipe_rotations[wrong_pipe_idx]:
			break
		pipe_rotations[wrong_pipe_idx] = (pipe_rotations[wrong_pipe_idx] + 1) % 4
		pipe_sprites[wrong_pipe_idx].rotation_degrees = pipe_rotations[wrong_pipe_idx] * 90


func choose_pipe_type(needed_dirs: Array[Vector2i]) -> String:
	if needed_dirs.size() <= 1:
		return "pipe_end"

	if needed_dirs.size() == 2:
		var diff = needed_dirs[0] - needed_dirs[1]
		# Opposite directions (like left-right or up-down) have diff with magnitude 2
		if abs(diff.x) == 2 or abs(diff.y) == 2:
			return "straight"
		else:
			return "corner"
	if needed_dirs.size() == 3:
		return "triple"

	return "cross"

func get_pipe_texture(pipe_type: String) -> Texture2D:
	match pipe_type:
		"straight": return pipe_straight
		"corner": return pipe_corner
		"triple": return pipe_triple
		"cross": return pipe_cross
		"pipe_end": return pipe_end
	return pipe_straight

func find_correct_rotations(pipe_type: String, needed_dirs: Array) -> Array[int]:
	var rotations: Array[int] = []
	for rot in range(4):
		var connections = rotate_pipe_connections(pipe_type, rot)
		var all_connected = true
		for dir in needed_dirs:
			if dir not in connections:
				all_connected = false
				break
		if all_connected:
			rotations.append(rot)
	return rotations

const PIPE_CONNECTIONS = {
	"straight": [Vector2i(-1, 0), Vector2i(1, 0)],
	"corner": [Vector2i(1, 0), Vector2i(0, -1)],
	"triple": [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0)],
	"cross": [Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1)],
	"pipe_end": [Vector2i(1, 0)],
}

func rotate_pipe_connections(pipe_type: String, rotation: int) -> Array[Vector2i]:
	var base_connections = PIPE_CONNECTIONS[pipe_type]
	var rotated_connections: Array[Vector2i] = []
	for conn in base_connections:
		var rotated = Vector2i()
		match rotation % 4:
			1:
				rotated = conn
			2:
				rotated = Vector2i(-conn.y, conn.x)
			3:
				rotated = Vector2i(-conn.x, -conn.y)
			0:
				rotated = Vector2i(conn.y, -conn.x)
		rotated_connections.append(rotated)
	return rotated_connections

func _input(event: InputEvent) -> void:
	if game_complete:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()

		for i in range(pipes.size()):
			var pipe = pipe_sprites[i]
			var click_radius = cell_size * 0.5

			if pipe.position.distance_to(mouse_pos) < click_radius:
				rotate_pipe(i)
				break

func rotate_pipe(index: int) -> void:
	pipe_rotations[index] = (pipe_rotations[index] + 1) % 4
	check_win_condition()

func _process(delta: float) -> void:
	for i in range(pipe_sprites.size()):
		var pipe = pipe_sprites[i]

		# # Update color based on correctness
		# if pipe_rotations[i] in correct_pipe_rotations[i]:
		# 	pipe.modulate = Color(0.8, 1.0, 0.8)
		# else:
		# 	pipe.modulate = Color(1.0, 1.0, 1.0)

		var target_rotation = pipe_rotations[i] * 90.0
		var current_rotation = pipe.rotation_degrees

		# Handle wrap-around from 270 to 0
		if pipe_rotations[i] == 0 and current_rotation > 180:
			# Rotate towards 360 instead of 0
			target_rotation = 360.0
			current_rotation = lerp(current_rotation, target_rotation, delta * 20)
			if current_rotation >= 359:
				current_rotation = 0.0
			pipe.rotation_degrees = current_rotation
		elif abs(current_rotation - target_rotation) > 0.1:
			pipe.rotation_degrees = lerp(current_rotation, target_rotation, delta * 20)
		else:
			pipe.rotation_degrees = target_rotation

func check_win_condition() -> void:
	for i in range(pipes.size()):
		if pipe_rotations[i] not in correct_pipe_rotations[i]:
			return
	on_puzzle_complete()

func on_puzzle_complete() -> void:
	if game_complete:
		return
	game_complete = true
	await get_tree().create_timer(0.5).timeout
	manager.finish_objective()
