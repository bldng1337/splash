class_name GameManager
extends Node

@export var games: Array[PackedScene]=[
	preload("res://content/W2/L2/main.tscn"),
	preload("res://content/W2/river/main.tscn"),
	preload("res://content/W1/L1/main.tscn"),
	preload("res://content/W3/L1/main.tscn"),
]

var current_game: Node
var current_game_index: int = 0

var objectives: int = 0
var lives: int = 3

func fail() -> void:
	lives -= 1
	print("Fail %s" % lives)
	next_game()

func register_objective() -> void:
	objectives += 1

func finish_objective() -> void:
	print("Objective %s finished" % objectives)
	objectives -= 1
	if objectives == 0:
		next_game()

func next_game() -> void:
	print("Next game %s" % randi())
	var last_game_index=current_game_index
	while current_game_index==last_game_index:
		current_game_index = randi() % games.size()
	if current_game!=null:
		current_game.queue_free()
	objectives=0
	current_game = games[current_game_index].instantiate()
	add_child(current_game)
	# get_tree().change_scene_to_packed(games[current_game_index])

func _ready() -> void:
	next_game()
