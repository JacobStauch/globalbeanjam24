# This script should be attached to every bean object.
extends Node2D

@onready var promptHandler = $PromptHandler
@onready var signalBus = get_node("/root/SignalBus")

signal dialogue_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	print("bean ready")
	promptHandler.promptDoneSignal.connect(_on_prompt_done)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_prompt_done():
	signalBus.beanPromptDoneSignal.emit(self)

func _on_dialogue_box_dialogue_box_finished():
	emit_signal("dialogue_finished")


func _on_game_manager_new_bean_created():
	emit_signal("dialogue_finished")
