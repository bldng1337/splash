class_name Drop
extends Node2D

@export var sprite: Sprite2D

var is_shit: bool = false
var speed: float = 250

func _ready() -> void:
	is_shit=randi()%2==0
	if is_shit:
		sprite.texture = load("res://assets/W2L2/kaka%d.png" % (1+randi() % 3))
	else:
		sprite.texture = load("res://assets/W2L2/Raindrop%d.png" % (1+randi() % 5))


func _process(delta: float) -> void:
	speed+=delta*600
	global_position+=Vector2(0,speed*delta)
