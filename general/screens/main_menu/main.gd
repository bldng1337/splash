extends Node

const easy_selected=preload("res://assets/ui/easy_sel.png")
const easy=preload("res://assets/ui/easy.png")

const hard_selected=preload("res://assets/ui/hard_sel.png")
const hard=preload("res://assets/ui/hard.png")

@export var easy_button: Button
@export var hard_button: Button
@export var start_button: Button

func _ready():
	easy_button.pressed.connect(_on_easy_button_pressed)
	hard_button.pressed.connect(_on_hard_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	update()

func update():
	print("Updating difficulty selection UI")
	if manager.easy:
		easy_button.icon = easy_selected
		hard_button.icon = hard
	else:
		easy_button.icon = easy
		hard_button.icon = hard_selected

func _on_easy_button_pressed():
	manager.easy = true
	update()

func _on_hard_button_pressed():
	manager.easy = false
	update()

func _on_start_button_pressed():
	manager.reset_game()
