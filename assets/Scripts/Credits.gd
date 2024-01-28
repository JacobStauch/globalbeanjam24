extends Control

@onready var go_back_button = $GoBackButton

func _ready():
	go_back_button.grab_focus()

func _on_go_back_button_pressed():
	get_tree().change_scene_to_file("res://assets/Scenes/Objects/MainMenu.tscn")
