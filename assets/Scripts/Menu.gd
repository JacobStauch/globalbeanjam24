extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	if (get_tree().get_current_scene().get_name() == "MainMenu"):
		$VBoxContainer/StartButton.grab_focus()
	elif (get_parent().is_visible()):
		$CenterContainer/BackgroundPanel/VBoxContainer/MenuButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://assets/Scenes/TestLevels/SaladTest.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://assets/Scenes/Objects/MainMenu.tscn")
