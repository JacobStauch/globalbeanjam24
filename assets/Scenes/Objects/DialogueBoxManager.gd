extends Node2D

signal dialogue_box_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_dialogue_box_dialogue_finished():
	emit_signal("dialogue_box_finished")
