extends Node

const WIN_VIDEO=[
	preload("res://assets/win_tween/close.ogv"),
	preload("res://assets/win_tween/middle.ogv"),
	preload("res://assets/win_tween/opening.ogv"),
]

const LOOSE_VIDEO=[
	preload("res://assets/loose_tween/opening.ogv"),
	preload("res://assets/loose_tween/middle.ogv"),
	preload("res://assets/loose_tween/close.ogv"),
]

@export var first:VideoStreamPlayer
@export var second:VideoStreamPlayer
@export var third:VideoStreamPlayer

@export var first_life:Control
@export var second_life:Control
@export var third_life:Control

@export var is_loose:bool
@export var label:Label

func getvids():
	if is_loose:
		return LOOSE_VIDEO
	else:
		return WIN_VIDEO


func _ready() -> void:
	manager.ticking=false
	first.stream = getvids()[0]
	second.stream = getvids()[1]
	third.stream = getvids()[2]
	first.connect("finished", _on_first_stopped)
	second.connect("finished", _on_second_stopped)
	third.connect("finished", _on_third_stopped)
	var streams=[first, second, third]
	for stream in streams:
		stream.visible=false
		stream.play()
	await get_tree().create_timer(0.1).timeout
	for stream in streams:
		stream.paused=true
	first.play()
	first.paused=false
	first.visible=true
	label.text = str(manager.score) + "/" + str(manager.total_games)


func _on_first_stopped():
	second.play()
	second.visible=true
	second.paused=false
	first.visible=false
	label.visible=true
	await get_tree().create_timer(0.1).timeout
	var life=manager.lives
	first_life.visible=life>0
	second_life.visible=life>1
	third_life.visible=life>2
	await get_tree().create_timer(0.9).timeout
	label.visible=true
	await get_tree().create_timer(1.6).timeout
	label.visible=false
	first_life.visible=false
	second_life.visible=false
	third_life.visible=false
	manager.next_game()


func _on_second_stopped():
	third.play()
	third.visible=true
	third.paused=false
	second.visible=false


func _on_third_stopped():
	manager.ticking=true
	queue_free()
