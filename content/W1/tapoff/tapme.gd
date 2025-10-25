extends Node2D

@export var button:Button

func _ready() -> void:
	manager.register_objective()
	button.connect("pressed", tap)


func tap():
	manager.finish_objective()
	queue_free()
