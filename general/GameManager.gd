class_name GameManager
extends Node

@export var games: Array[PackedScene]=[
	preload("res://content/W2/L2/main.tscn"),
	preload("res://content/W2/river/main.tscn"),
	preload("res://content/W1/L1/main.tscn"),
	preload("res://content/W3/L1/main.tscn"),
	preload("res://content/W1/L2/main.tscn"),
]

var game_over_screen: PackedScene = preload("res://general/screens/game_over/game_over.tscn")
var game_win_screen: PackedScene = preload("res://general/screens/win/win_screen.tscn")
var tween_screen=preload("res://general/screens/tween/tween.tscn")

var global_time=0
var score=0
var current_game: Node
var current_game_index: int = 0
var current_screen: Node

var objectives: int = 0
var lives: int = 3
var num_games=0
var total_games=15
var easy=true

var base_time: float = 15.0
var game_time: float = 0.0
var ticking=true

var running=true

const main_menu=preload("res://general/screens/main_menu/main_menu.tscn")

func go_main_menu():
	var iscreen = main_menu.instantiate()
	ticking=false
	add_child(iscreen)
	if current_screen!=null:
		current_screen.queue_free()
	current_screen=iscreen
	if current_game!=null:
		current_game.queue_free()
	current_game=null

func reset_game() -> void:
	current_screen.queue_free()
	current_screen=null
	lives = 3
	num_games = 0
	score = 0
	running=true
	ticking=true
	global_time=int(Time.get_ticks_msec()/1000.0)
	next_game()

func get_game_time() -> float:
	return game_time

func get_game_duration() -> float:
	var diff=get_difficulty()
	return base_time*(1-diff*0.6)+4

func get_remaining_time() -> float:
	var total_time=get_game_duration()
	var used_time=get_game_time()
	return max(total_time-used_time,0.0)

func get_difficulty() -> float:# 0 easy - 1 hard
	var normal=1-(1.0/(1.0+(num_games*num_games)*0.1))
	if not easy:
		normal=0.5+normal
	return normal

func fail() -> void:
	if not running:
		return
	lives -= 1
	animate_next(true)

func register_objective() -> void:
	if not running:
		return
	objectives += 1

func finish_objective() -> void:
	if not running:
		return
	objectives -= 1
	if objectives == 0:
		animate_next(false)

func animate_next(loose:bool) -> void:
	running=false
	if lives <= 0:
		var game_over = game_over_screen.instantiate()
		ticking=false
		add_child(game_over)
		current_screen=game_over
		if current_game!=null:
			current_game.queue_free()
		return
	if manager.score>=total_games:
		var game_over = game_win_screen.instantiate()
		ticking=false
		add_child(game_over)
		current_screen=game_over
		if current_game!=null:
			current_game.queue_free()
		return
	var overlay=tween_screen.instantiate()
	overlay.is_loose=loose
	add_child(overlay)

func next_game() -> void:
	score+=1
	num_games+=1
	running=true
	print("Current Game number: %d" % num_games)
	print("Difficulty: %.2f" % get_difficulty())
	objectives = 0
	var last_game_index=current_game_index
	for _i in range(100):
		if current_game_index != last_game_index:
			break
		current_game_index = randi() % games.size()
	if current_game!=null:
		current_game.queue_free()
	objectives=0
	game_time=0
	current_game = games[current_game_index].instantiate()
	add_child(current_game)

func _ready() -> void:
	go_main_menu()
	pass

func _process(delta: float) -> void:
	if ticking:
		game_time+=delta
