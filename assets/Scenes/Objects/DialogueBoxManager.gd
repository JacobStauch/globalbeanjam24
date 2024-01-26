extends Node2D

@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogueBox.dialogue_finished.connect(_on_dialogue_box_dialogue_finished)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_dialogue_box_dialogue_finished():
	signalBus.dialogueBoxFinishedSignal.emit()
