extends Node2D

@onready var signalBus = get_node("/root/SignalBus")
@onready var bean = preload("res://assets/Scenes/Objects/BasicBean.tscn")

signal new_bean_created

var beansKilled = 0

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
	beansKilled += 1
	print("Beans Killed: ", beansKilled)
	var newBeanInstance = bean.instantiate()
	add_sibling(newBeanInstance)
	emit_signal("new_bean_created")
