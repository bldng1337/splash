extends Node

@export var score_label: Label
@export var time_label: Label


func _ready() -> void:
	score_label.text = "%d" % manager.score
	var total_time = (Time.get_ticks_msec()/1000.0) - manager.global_time
	time_label.text = "%.2f" % total_time
