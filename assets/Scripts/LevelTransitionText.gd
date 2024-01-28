extends RichTextLabel

@onready var signalBus = get_node("/root/SignalBus")

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 428), 1)
	tween.tween_property(self, "position", Vector2(0, 428), 1)
	tween.tween_property(self, "position", Vector2(0, 1284), 1)
	tween.tween_callback(self.queue_free)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


