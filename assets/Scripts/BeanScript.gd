# This script should be attached to every bean object.
extends Node2D

@onready var promptHandler = $PromptHandler
@onready var movementController = $MovementControl
@onready var signalBus = get_node("/root/SignalBus")
@onready var camera = %Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	promptHandler.promptDoneSignal.connect(_on_prompt_done)
	promptHandler.beanSelected.connect(_on_bean_selected)
	movementController.timeoutSignal.connect(_on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_prompt_done():
	# Bubble up the prompt Done signal with the Bean node that triggered it
	signalBus.beanPromptDoneSignal.emit(self)
	var tween = get_tree().create_tween().set_parallel(true)
	var cameraPosition = camera.get_screen_center_position()
	var direction = 2000
	if (position.x < cameraPosition.x):
		direction = direction * -1
	tween.tween_property(self, "position", Vector2(direction, -750), 1)
	tween.tween_property(self, "rotation_degrees", 800.0, 1).as_relative()

func _on_bean_selected():
	signalBus.beanSelectedSignal.emit(self)

func _on_timeout():
	signalBus.beanAtEndSignal.emit(self)

func get_bean_path_num():
	return movementController.get_path_number()

