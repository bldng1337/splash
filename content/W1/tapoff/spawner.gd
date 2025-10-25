extends Node2D

@export var entity: PackedScene
@export var amount: int = 1
@export var range: float = 100


func _ready():
	for i in range(amount):
		var e = entity.instantiate()
		e.position = Vector2(randf_range(-range, range), randf_range(-range, range))
		add_child(e)
