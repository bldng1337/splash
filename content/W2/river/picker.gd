extends Node


@export var collection: Node2D
@export var trash: Node2D

var _picked_up: Node2D

func _ready() -> void:
	for c in collection.get_children():
		c.picked_up=false



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and _picked_up==null:
			print("searching for %s" % event.global_position)
			for c in collection.get_children():
				print(c.global_position.distance_to(event.global_position))
				if c.global_position.distance_to(event.global_position)<50:
					pickup(c)
					break
		else:
			if _picked_up:
				if _picked_up.global_position.distance_to(trash.global_position)<200:
					manager.finish_objective()
					_picked_up.queue_free()
				_picked_up.picked_up=false
			_picked_up=null


func pickup(node: Node2D) -> void:
	print("picked up %s" % node.name)
	node.picked_up=true
	_picked_up=node
	pass
