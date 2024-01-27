# This script should be attached to every bean object.
extends Node2D

@onready var promptHandler = $PromptHandler
@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	promptHandler.promptDoneSignal.connect(_on_prompt_done)
	promptHandler.beanSelected.connect(_on_bean_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_prompt_done():
	# Bubble up the prompt Done signal with the Bean node that triggered it
	signalBus.beanPromptDoneSignal.emit(self)

func _on_bean_selected():
	signalBus.beanSelectedSignal.emit(self)
