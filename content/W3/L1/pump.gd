extends Node2D

@export var pump_sprite: Sprite2D
@export var level: Polygon2D

var low=355.0
var high=495.0

var low_level=414.0
var high_level=399.0

var curr_level=0.0
var last_pump_pos=0.0

# func pump_up() -> void:
# 	curr_level+=0.1-curr_level*0.05

func _ready() -> void:
	manager.register_objective()

func _process(delta: float) -> void:
	var pump_level=(pump_sprite.position.y-low)/(high-low)
	var pump_delta=pump_level-last_pump_pos
	last_pump_pos=pump_level
	pump_delta=max(pump_delta,0.0)
	curr_level+=pump_delta*0.1
	if curr_level>1.0:
		curr_level=1.0
		manager.finish_objective()
	curr_level-=delta*0.01+(curr_level*curr_level)*0.002
	if(curr_level<0):
		curr_level=0.0
	level.scale.y=curr_level*2.5
	level.position.y=(low_level+(high_level-low_level)*curr_level)
