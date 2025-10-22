extends Node2D

@export var button:Button

var game_manager:GameManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager=get_tree().root.get_node("%manager")
	game_manager.register_objective()
	button.connect("pressed",self.tap)
	

func tap():
	game_manager.finish_objective()
