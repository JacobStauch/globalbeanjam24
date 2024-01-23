extends Node2D

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var letterTyped = OS.get_keycode_string(event.unicode)
		if letterTyped == "a":
			print("Pausing")
			get_tree().paused = !get_tree().paused
			


func _on_button_pressed():
	print("Pausing")
	get_tree().paused = !get_tree().paused
