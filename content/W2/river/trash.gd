extends Node2D

@export var sprite: Sprite2D
@export var path: Path2D
@export var speed: float = 200
var _relpos: Vector2
var _offset: float
var _len:float
var picked_up: bool = false


func _ready() -> void:
	if sprite:
		var idx: int = 1+randi() % 3
		sprite.texture = load("res://assets/W2LVL1/müll%d.png" % idx)
	var local_pos: Vector2 = path.to_local(global_position)
	_offset = path.curve.get_closest_offset(local_pos)
	_relpos = path.curve.get_closest_point(local_pos)-local_pos
	_len=path.curve.get_baked_length()

func getpos() -> Vector2:
	var newpos=path.curve.sample_baked(_offset,true)+_relpos
	return path.to_global(newpos)


var time=0;

func _process(delta: float) -> void:
	if picked_up:
		global_position=lerp(global_position,get_global_mouse_position(),delta*20)
		return
	_offset+=delta*speed
	time+=delta
	rotation_degrees=sin(time)*2*15
	if _offset>_len:
		manager.fail()
		queue_free()
		return
	global_position=getpos()
	pass
