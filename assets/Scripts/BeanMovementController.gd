extends Node2D

signal timeoutSignal
@onready var signalBus = get_node("/root/SignalBus")

@onready var timer = $"./MovementTimer"
@onready var root = $".."
var i = 0
var canMove = false

var path: Array = [{"x": 0.0, "y": 0.0, "scale": 1.0}] # Default
var pathNum
var level_data

func _ready():
	root.transform = get_transform_from_point_idx(0)
	
	var file = FileAccess.open("res://assets/Text/level_transforms.json", FileAccess.READ)
	var jsonContent = file.get_as_text()
	var json = JSON.new()
	var e = json.parse(jsonContent)
	level_data = json.data

func _on_movement_timer_timeout():
	print("timer timeout")
	i = i + 1
	if i >= len(path):
		if !root.isBoss:
			timer.stop()
			timeoutSignal.emit()
			return
		i = 0
		print("Boss resetting to 0")
	
	var next = path[i]
	root.transform = get_transform_from_point_idx(i)

func get_transform_from_point_idx(i):
	var next = path[i]
	return Transform2D(0, Vector2(next["scale"], next["scale"]), 0, Vector2(next["x"], next["y"]))

func set_path(new_path, pathNumber):
	pathNum = pathNumber
	path = new_path

func get_path_number():
	return pathNum
