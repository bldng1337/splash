extends Node

@export var score_label: Label
@export var time_label: Label
@export var try_again_button: Button
@export var main_menu_button: Button

func _ready() -> void:
	score_label.text = "%d" % manager.score
	var total_time = (Time.get_ticks_msec()/1000.0) - manager.global_time
	time_label.text = "%.2f" % total_time
	try_again_button.pressed.connect(on_try_again_pressed)

func on_try_again_pressed() -> void:
	manager.reset_game()
