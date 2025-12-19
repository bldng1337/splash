extends Label

func _process(delta: float) -> void:
	var remaining_time=manager.get_remaining_time()
	text="Time: %.2f" % remaining_time
	if remaining_time<=0.0:
		manager.fail()
