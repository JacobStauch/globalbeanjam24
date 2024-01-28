# This script should be attached to every bean object.
extends Node2D
class_name BeanScript

@onready var promptHandler = $PromptHandler
@onready var movementController = $MovementControl
@onready var signalBus = get_node("/root/SignalBus")
@onready var boss_attack_timer = $BossAttackTimer

var isBoss = false

@onready var camera = get_viewport().get_camera_2d()
@onready var timer = $"./MovementControl/MovementTimer"


# Called when the node enters the scene tree for the first time.
func _ready():
	promptHandler.promptDoneSignal.connect(_on_prompt_done)
	promptHandler.beanSelected.connect(_on_bean_selected)
	movementController.timeoutSignal.connect(_on_timeout)
	if isBoss:
		boss_attack_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_prompt_done():
	# Bubble up the prompt Done signal with the Bean node that triggered it
	timer.stop()
	signalBus.beanPromptDoneSignal.emit(self)
	var cameraPosition = camera.get_screen_center_position()
	var direction = 2000
	if (position.x < cameraPosition.x):
		direction = direction * -1
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(direction, -750), 1)
	tween.tween_property(self, "rotation_degrees", 800.0, 1).as_relative()
	tween.connect("finished", on_tween_finished)

func on_tween_finished():
	print("Destroying Bean")
	self.queue_free()

func _on_bean_selected():
	signalBus.beanSelectedSignal.emit(self)

func _on_timeout():
	signalBus.beanAtEndSignal.emit(self)

func get_bean_path_num():
	return movementController.get_path_number()

func _on_boss_attack_timer_timeout():
	signalBus.beanAtEndSignal.emit(self)
	print("Boss attacks")
