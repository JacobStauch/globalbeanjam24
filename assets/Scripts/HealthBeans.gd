extends HBoxContainer

@onready var signalBus = get_node("/root/SignalBus")

func _ready():
	# Connect signals
	signalBus.dialogueBoxFinishedSignal.connect(_on_dialogue_box_finished)

func update_health(value):
	for i in get_child_count():
		get_child(i).visible = value > i
		set_size(Vector2(size.x - 60, size.y))
		
func _on_dialogue_box_finished(currentState):
	show()
