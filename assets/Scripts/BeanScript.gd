# This script should be attached to every bean object.
extends Node2D

@onready var promptHandler = $PromptHandler
@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	promptHandler.promptDoneSignal.connect(_on_prompt_done)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_prompt_done():
	signalBus.beanPromptDoneSignal.emit(self)
	
