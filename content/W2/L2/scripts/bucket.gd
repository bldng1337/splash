@tool
extends Node2D

const drops=[
	preload("res://assets/W2L2/drop1.wav"),
	preload("res://assets/W2L2/drop2.wav")
]

@export var shape: Shape2D:
	set(new_value):
		if shape == new_value:
			return

		if shape != null and shape.changed.is_connected(queue_redraw):
			shape.changed.disconnect(queue_redraw)

		shape = new_value

		if shape != null and not shape.changed.is_connected(queue_redraw):
			shape.changed.connect(queue_redraw)

		queue_redraw()

@export var collection: Node2D

var last_position: float
var velocities: Array[float] = []

func _ready() -> void:
	global_position.x = get_global_mouse_position().x
	last_position = global_position.x

func process_movement(delta:float):
	global_position.x =get_global_mouse_position().x
	var velocity = global_position.x - last_position
	velocity=velocity*delta*150
	last_position = global_position.x
	velocities.push_back(velocity)
	if velocities.size() > 10:
		velocities.pop_front()
	var avg_velocity = 0.0
	for v in velocities:
		avg_velocity += v
	avg_velocity /= velocities.size()
	return avg_velocity

func play_drop_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = drops.pick_random()
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.volume_db = -7.0
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	rotation_degrees = clamp(process_movement(delta), -15, 15)
	var node_shape=CircleShape2D.new()
	node_shape.radius=10
	for node:Node2D in collection.get_children():
		if shape.collide(global_transform,node_shape,node.global_transform):
			node.queue_free()
			play_drop_sound()
			if node.is_shit:
				manager.fail()
				return
			manager.finish_objective()

func _draw() -> void:
	if Engine.is_editor_hint() and shape != null:
		shape.draw(get_canvas_item(), Color(0, 1, 1, 0.3))
