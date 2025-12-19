extends Node2D

const dirty_textures= [
	preload("res://assets/W1L2/glass1_dirty.png"),
	preload("res://assets/W1L2/glass2_dirty.png"),
	preload("res://assets/W1L2/glass3_dirty.png"),
	preload("res://assets/W1L2/glass4_dirty.png"),
]

const clean_textures= [
	preload("res://assets/W1L2/glass1_clean.png"),
	preload("res://assets/W1L2/glass2_clean.png"),
	preload("res://assets/W1L2/glass3_clean.png"),
	preload("res://assets/W1L2/glass4_clean.png"),
]

@export var click_label: Label
const hider_texture: Texture2D = preload("res://assets/temp.png")

var num_glasses:int=5
var glasses:Array= []
const glass_height: int = 1200

class Glass:
	var node: Sprite2D
	var hider: Node2D#The thing that hides the glass
	var hidden: bool = false
	var is_clean: bool = false
	var want_pos: Vector2

	func init():
		node = Sprite2D.new()
		node.scale = Vector2(0.1, 0.1)
		is_clean = randi() % 2 == 0
		if is_clean:
			node.texture = clean_textures[randi() % clean_textures.size()]
		else:
			node.texture = dirty_textures[randi() % dirty_textures.size()]
		hider = Sprite2D.new()
		hider.texture = hider_texture
		hider.modulate = Color(0, 0, 0)
		hider.position = Vector2(0, -glass_height)
		hider.scale = Vector2(2, 6)
		node.add_child(hider)
		want_pos = node.position

	func hide() -> void:
		hidden = true

	func reveal() -> void:
		hidden = false

	func update(delta:float) -> void:
		hider.position.y = lerp(hider.position.y, float(0 if hidden else -glass_height), delta*5)
		node.position = lerp(node.position, want_pos, delta*3)

var start=false
var is_ready=false

func _ready() -> void:
	num_glasses=3+int(manager.get_difficulty()*2)
	spawn_glasses()

func spawn_glasses() -> void:
	var center = get_viewport().get_visible_rect().size/2
	center.y += 50
	for i in range(num_glasses):
		var glass = Glass.new()
		glass.init()
		if glass.is_clean:
			manager.register_objective()
		var spacing = 100
		var total_width = (num_glasses - 1) * spacing
		var x = center.x - total_width / 2.0 + i * spacing
		var y = center.y
		glass.node.position = Vector2(x, y)
		glass.want_pos= glass.node.position
		add_child(glass.node)
		glasses.append(glass)
	var random_idx=int(randi()%num_glasses)
	glasses[random_idx].is_clean=true
	glasses[random_idx].node.texture=clean_textures[randi()%clean_textures.size()]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not start:
			start=true
			click_label.hide()
			swap()
		if is_ready:
			var mouse_pos = get_global_mouse_position()
			for glass in glasses:
				if glass.node.global_position.distance_to(mouse_pos) < 50:
					glass.reveal()
					if glass.is_clean:
						manager.finish_objective()
					else:
						manager.fail()

func _process(delta: float) -> void:
	for glass in glasses:
		glass.update(delta)


func swap():
	var duration=manager.get_game_duration()
	var swap_time=duration*0.65
	var swaps=int(manager.get_difficulty()*2+1)
	var interval=swap_time/(swaps+1)
	for glass in glasses:
		glass.hide()
	for i in range(swaps):
		await get_tree().create_timer(interval).timeout
		var a=int(randi()%num_glasses)
		var b=int(randi()%num_glasses)
		for _i in range(100):
			if a!=b:
				break
			b=int(randi()%num_glasses)
		var temp=glasses[a].want_pos
		glasses[a].want_pos=glasses[b].want_pos
		glasses[b].want_pos=temp
	is_ready=true
	click_label.text="Click the CLEAN glasses!"
	click_label.show()
