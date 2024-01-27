extends Node2D

@onready var signalBus = get_node("/root/SignalBus")

@onready var timer = $"./MovementTimer"
@onready var root = $".."
var i = 0
var canMove = false

var path: Array = [{"x": 0.0, "y": 0.0, "scale": 1.0}] # Default

func _ready():
	root.transform = get_transform_from_point_idx(0)

func _on_movement_timer_timeout():
	print("timer timeout")
	i = i + 1
	if i >= len(path):
		timer.stop()
		signalBus.beanAtEndSignal.emit()
		return
	
	var next = path[i]
	root.transform = get_transform_from_point_idx(i)

func get_transform_from_point_idx(i):
	var next = path[i]
	return Transform2D(0, Vector2(next["scale"], next["scale"]), 0, Vector2(next["x"], next["y"]))

func set_path(new_path):
	path = new_path
