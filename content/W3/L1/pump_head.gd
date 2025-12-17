extends Node2D

var low=315.0
var high=450.0

var hold=false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if global_position.distance_to(event.global_position)<60:
				hold=true
		else:
			hold=false


func _process(delta: float) -> void:
	if hold:
		global_position.y=clamp(get_global_mouse_position().y,low,high)
