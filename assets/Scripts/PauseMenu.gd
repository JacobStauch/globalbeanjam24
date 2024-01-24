extends Control

signal quit
signal resume

func _on_resume_button_pressed():
	resume.emit()

func _on_quit_button_pressed():
	quit.emit()
