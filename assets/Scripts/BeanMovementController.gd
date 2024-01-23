extends Node2D

@onready var path_manager = get_tree().get_nodes_in_group("BenTest_Managers").filter(func(obj): return obj.name == "PathManager")[0] # TODO: wow i sure hate this
@onready var timer = $"./MovementTimer"
@onready var root = $".."
var i = 0

signal at_end

func _ready():
	root.transform = path_manager.get_next_pos(-1)

func _on_movement_timer_timeout():
	var next = path_manager.get_next_pos(i)
	
	if next == null:
		timer.stop()
		at_end.emit()
	else:
		root.transform = next
	i = i + 1
