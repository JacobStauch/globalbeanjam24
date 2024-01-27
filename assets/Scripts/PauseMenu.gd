extends Control

@onready var this = $"."

func togglePause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		this.show()
	else:
		this.hide()

func _on_resume_button_pressed():
	togglePause()

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/Scenes/Objects/MainMenu.tscn")

func _input(event):
	if event.is_action_pressed("Pause"):
		togglePause()
