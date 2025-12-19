extends Node


@export var collection: Node2D
@export var trash: Node2D
@export var effect: PackedScene

var _picked_up: Node2D

func _ready() -> void:
	scale=trash.scale
	for c in collection.get_children():
		c.picked_up=false



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and _picked_up==null:
			for c in collection.get_children():
				if c.global_position.distance_to(event.global_position)<130:
					pickup(c)
					break
		else:
			if _picked_up:
				if is_hovered(_picked_up):
					manager.finish_objective()
					var despawn_effect = effect.instantiate()
					add_child(despawn_effect)
					despawn_effect.global_position=_picked_up.global_position
					despawn_effect.rotation_degrees=_picked_up.rotation_degrees
					_picked_up.queue_free()
				_picked_up.picked_up=false
			_picked_up=null

var scale: Vector2

func _process(delta: float) -> void:
	# if not _picked_up:
	# 	return
	if is_hovered(_picked_up):
		trash.scale+=delta*Vector2(1,1)
		var max_scale=scale*1.1
		if trash.scale.x>max_scale.x:
			trash.scale.x=max_scale.x
		if trash.scale.y>max_scale.y:
			trash.scale.y=max_scale.y
	else:
		trash.scale-=delta*Vector2(3,3)
		if trash.scale.x<scale.x:
			trash.scale.x=scale.x
		if trash.scale.y<scale.y:
			trash.scale.y=scale.y


func is_hovered(node: Node2D) -> bool:
	if not node:
		return false
	return node.global_position.distance_to(trash.global_position)<200

func pickup(node: Node2D) -> void:
	node.picked_up=true
	_picked_up=node
	pass
