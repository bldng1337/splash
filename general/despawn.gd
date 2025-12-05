class_name Despawn
extends Node

var timer: float = 0.0
@export var despawn_time: float = 1.0

func _process(delta: float) -> void:
	timer += delta
	if timer > despawn_time:
		queue_free()
