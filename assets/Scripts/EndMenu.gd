extends Node

var wpm = 20
var beansEaten = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	$WPMText.bbcode_text = "WPM: " + str(wpm)
	$BeansEatenText.bbcode_text = "Beans Eaten: " + str(beansEaten)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
