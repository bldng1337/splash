extends Node2D

@export var entity: PackedScene
@export var spawn_range=100.0
@export var amount=3.5
@export var path: Path2D
@export var delay=0.8

var _timer: float = 0.0
var _spawned: int = 0

func _ready():
	amount=floor(amount*randf_range(0,1))

func _process(delta):
	_timer += delta
	if _timer > delay:
		_timer = 0.0
		_spawned += 1
		if _spawned < amount:
			var e: Node2D = entity.instantiate()
			e.position = Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
			e.path=path
			e.z_index=1
			add_child(e)
