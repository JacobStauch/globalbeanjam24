extends Node2D

@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	signalBus.beanPromptDoneSignal.connect(_on_bean_prompt_done)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_bean_prompt_done(beanInstance):
	print("Prompt done signal received")
	print("Found Node from signal: ", beanInstance.get_name())
	print("Deleting bean")
	beanInstance.queue_free()
