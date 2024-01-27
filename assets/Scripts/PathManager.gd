extends Node2D

signal load_levels_success
signal load_levels_failure

var level_data: Dictionary
var current_level = "kingdom" # Default

func _ready():
	var file = FileAccess.open("res://assets/Text/level_transforms.json", FileAccess.READ)
	var jsonContent = file.get_as_text()
	var json = JSON.new()
	var e = json.parse(jsonContent)
	if e != OK:
		load_levels_failure.emit()
		print("Failed to load json: %s" % e)
		return
	level_data = json.data
	load_levels_success.emit()

func _convertToTransform2D(x: float, y: float, s: float) -> Transform2D:
	return Transform2D(0, Vector2(s, s), 0, Vector2(x, y))

func get_next_pos(idx: int):
	if len(level_data[current_level]) <= idx + 1:
		return null
	
	var pos = level_data[current_level][idx + 1]
	return _convertToTransform2D(pos["x"], pos["y"], pos["scale"])

func get_random_path():
	return level_data[current_level]
