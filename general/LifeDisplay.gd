extends Label

func _setup():
	manager.hud.push_back(self)

func _process(_delta: float) -> void:
	if manager.lives==0:
		self.visible=false
		return
	self.visible=true
	text="Lives: %d" % manager.lives
