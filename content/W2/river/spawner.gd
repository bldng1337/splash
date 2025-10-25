extends Node2D

@export var entity: PackedScene
@export var spawn_range=100.0
@export var amount=10
@export var path: Path2D

func _ready():
	for i in range(amount):
		var e: Node2D = entity.instantiate()
		e.position = Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
		e.path=path
		e.z_index=1
		add_child(e)
