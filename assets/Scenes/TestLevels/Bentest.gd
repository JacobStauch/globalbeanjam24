extends Node2D

@onready var pm = $"../PathManager"

var i = 0;

func _ready():
	$".".transform = pm.get_next_pos(-1)

func _on_timer_timeout():
	var nextPos = pm.get_next_pos(i)
	
	if nextPos == null:
		print("Boom")
		$Timer.stop()
	else:
		$".".transform = nextPos
	i = i + 1
