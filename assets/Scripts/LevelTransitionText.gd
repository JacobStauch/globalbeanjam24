extends RichTextLabel

@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame # Godot jank
	
	var timer = get_node("../Timer")
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 428), 1)
	tween.tween_property(self, "position", Vector2(0, 428), 1)
	tween.tween_property(self, "position", Vector2(0, 1284), 1)
	tween.tween_callback(self.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	print("Timer timed out")
	signalBus.levelTransitionFinished.emit()
