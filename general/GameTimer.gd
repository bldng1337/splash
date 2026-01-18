extends Label

func _setup():
	manager.hud.push_back(self)

func _process(_delta: float) -> void:
	if manager.lives==0 or manager.current_screen!=null:
		self.visible=false
		return
	self.visible=true
	var remaining_time=manager.get_remaining_time()
	text="Time: %.2f" % remaining_time
	if remaining_time<=0.0:
		manager.fail()
