@tool
extends Node2D

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

func _ready() -> void:
	global_position.x = get_global_mouse_position().x

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	global_position.x =get_global_mouse_position().x
	var node_shape=CircleShape2D.new()
	node_shape.radius=10
	for node:Node2D in collection.get_children():
		if shape.collide(global_transform,node_shape,node.global_transform):
			node.queue_free()
			if node.is_shit:
				manager.fail()
				return
			manager.finish_objective()
			node.queue_free()


func _draw() -> void:
	if Engine.is_editor_hint() and shape != null:
		shape.draw(get_canvas_item(), Color(0, 1, 1, 0.3))
