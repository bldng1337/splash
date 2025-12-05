extends Node2D

var pipe_straight = preload("res://assets/W1L1/pipe_straight.png")
var pipe_corner = preload("res://assets/W1L1/pipe_corner.png")
var pipe_triple = preload("res://assets/W1L1/pipe_triple.png")
var pipe_cross = preload("res://assets/W1L1/Pipe_cross.png")

const PIPE_CONNECTIONS = {
	"straight": [0, 2],
	"corner": [0, 3],
	"triple": [0, 2, 3],
	"cross": [0, 1, 2, 3]
}

var grid_size: Vector2i = Vector2i(7, 5)
var cell_size: float = 120.0
var grid_offset: Vector2 = Vector2.ZERO

var path_cells: Array[Vector2i] = []
var path_directions: Array[Vector2i] = []

var pipes: Array[Sprite2D] = []
var pipe_types: Array[String] = []
var pipe_rotations: Array[int] = []
var required_connections: Array[Array] = []

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

func generate_path() -> void:

	path_cells.clear()
	path_directions.clear()

	var current = Vector2i(0, randi() % grid_size.y)
	path_cells.append(current)

	while current.x < grid_size.x - 1:
		var possible_moves: Array[Vector2i] = []

		possible_moves.append(Vector2i(1, 0))

		if current.y > 0 and randf() < 0.3:
			if path_cells.size() < 2 or path_cells[-2] != current + Vector2i(0, -1):
				possible_moves.append(Vector2i(0, -1))

		if current.y < grid_size.y - 1 and randf() < 0.3:
			if path_cells.size() < 2 or path_cells[-2] != current + Vector2i(0, 1):
				possible_moves.append(Vector2i(0, 1))

		var move = possible_moves[randi() % possible_moves.size()]
		path_directions.append(move)
		current = current + move

		if current in path_cells:
			path_directions.pop_back()
			current = path_cells[-1]
			# move = Vector2i(1, 0)
			# path_directions.append(move)
			# current = current + move

		path_cells.append(current)

	path_directions.append(Vector2i(0, 0))

func direction_to_index(dir: Vector2i) -> int:
	if dir == Vector2i(0, -1): return 0  # up
	if dir == Vector2i(1, 0): return 1   # right
	if dir == Vector2i(0, 1): return 2   # down
	if dir == Vector2i(-1, 0): return 3  # left
	return -1

func opposite_direction(dir_index: int) -> int:
	return (dir_index + 2) % 4

func spawn_pipes() -> void:
	var guaranteed_wrong=1+floor(randf()*(path_cells.size()-2))
	for i in range(path_cells.size()):
		var cell = path_cells[i]
		var pos = Vector2(cell.x * cell_size + grid_offset.x, cell.y * cell_size + grid_offset.y)

		var needed_dirs: Array = []

		if i > 0:
			var from_dir = path_cells[i - 1] - cell
			var from_index = direction_to_index(from_dir)
			if from_index >= 0:
				needed_dirs.append(from_index)

		if i < path_cells.size() - 1:
			var to_dir = path_directions[i]
			var to_index = direction_to_index(to_dir)
			if to_index >= 0:
				needed_dirs.append(to_index)

		required_connections.append(needed_dirs)

		var pipe_type = choose_pipe_type(needed_dirs)
		pipe_types.append(pipe_type)

		var correct_rotation = find_correct_rotation(pipe_type, needed_dirs)

		var initial_rotation = randi() % 4
		if randf() < 0.3:
			initial_rotation = correct_rotation
		if i==0 or i==path_cells.size()-1:
			initial_rotation = correct_rotation
		if i==guaranteed_wrong:
			while initial_rotation==correct_rotation:
				initial_rotation = randi() % 4
		pipe_rotations.append(initial_rotation)

		var pipe_sprite = Sprite2D.new()
		pipe_sprite.texture = get_pipe_texture(pipe_type)
		pipe_sprite.position = pos
		pipe_sprite.rotation_degrees = initial_rotation * 90
		pipe_sprite.scale = Vector2(0.12, 0.12)

		add_child(pipe_sprite)
		pipes.append(pipe_sprite)

func choose_pipe_type(needed_dirs: Array) -> String:
	if needed_dirs.size() == 1:
		return "corner" if randf() < 0.5 else "straight"

	if needed_dirs.size() == 2:
		var diff = abs(needed_dirs[0] - needed_dirs[1])
		if diff == 2:
			return "straight"
		else:
			return "corner"

	return "cross"

func get_pipe_texture(pipe_type: String) -> Texture2D:
	match pipe_type:
		"straight": return pipe_straight
		"corner": return pipe_corner
		"triple": return pipe_triple
		"cross": return pipe_cross
	return pipe_straight

func find_correct_rotation(pipe_type: String, needed_dirs: Array) -> int:
	for rot in range(4):
		var connections = get_connections(pipe_type, rot)
		var all_connected = true
		for dir in needed_dirs:
			if dir not in connections:
				all_connected = false
				break
		if all_connected:
			return rot
	return 0

func get_connections(pipe_type: String, rotation: int) -> Array:
	var base_connections = PIPE_CONNECTIONS[pipe_type]
	var rotated_connections = []
	for conn in base_connections:
		rotated_connections.append((conn + rotation) % 4)
	return rotated_connections

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()

		for i in range(pipes.size()):
			var pipe = pipes[i]
			var click_radius = cell_size * 0.5

			if pipe.position.distance_to(mouse_pos) < click_radius:
				rotate_pipe(i)
				break

func rotate_pipe(index: int) -> void:
	pipe_rotations[index] = (pipe_rotations[index] + 1) % 4
	# pipes[index].rotation_degrees = pipe_rotations[index] * 90
	check_win_condition()

func _process(delta: float) -> void:
	for i in range(pipes.size()):
		var pipe = pipes[i]
		var target_rotation = pipe_rotations[i]
		if pipe.rotation_degrees != target_rotation * 90:
			if target_rotation == 4 or target_rotation == 0:
				var next_rotation = pipe.rotation_degrees + delta * 1000
				if next_rotation >= 360:
					next_rotation = 0
				pipe.rotation_degrees = next_rotation
				return
			pipe.rotation_degrees = lerp(pipe.rotation_degrees, target_rotation * 90.0, delta * 20)

func check_win_condition() -> void:
	for i in range(pipes.size()):
		var connections = get_connections(pipe_types[i], pipe_rotations[i])
		var needed = required_connections[i]

		for dir in needed:
			if dir not in connections:
				return

	on_puzzle_complete()

func on_puzzle_complete() -> void:
	manager.finish_objective()
