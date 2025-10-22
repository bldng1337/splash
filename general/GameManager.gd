class_name GameManager
extends Node

@export var games: Array[PackedScene]

var current_game: Node
var current_game_index: int = 0

var objectives: int = 0

func register_objective() -> void:
	objectives += 1

func finish_objective() -> void:
	objectives -= 1
	if objectives == 0:
		next_game()

func next_game() -> void:
	current_game_index = randi() % games.size()
	if current_game!=null:
		current_game.queue_free()
	current_game = games[current_game_index].instantiate()
	add_child(current_game)

func _ready() -> void:
	next_game()
