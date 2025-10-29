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

@export var spawn:PackedScene
@export var spawn_amount:int = 1
@export var delay:float = 0.0

var spawn_timer:float = 0.0
var numspawned:int =0

func _ready() -> void:
	print("Spawning %s" % spawn_amount)
	for i in range(spawn_amount):
		manager.register_objective()

func _process(delta:float) -> void:
	if numspawned>=spawn_amount:
		return
	spawn_timer += delta
	if spawn_timer < delay:
		return
	spawn_timer = 0.0
	var spawned = spawn.instantiate()
	add_child(spawned)
	var pos=shape.get_rect().position
	var size=shape.get_rect().size
	spawned.position = Vector2(randf_range(pos.x, pos.x+size.x), randf_range(pos.y, pos.y+size.y))
	numspawned+=1


func _draw() -> void:
	if Engine.is_editor_hint() and shape != null:
		shape.draw(get_canvas_item(), Color(0, 1, 1, 0.3))
