extends Node

var finalWPM = 0
var beansEaten = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$WPMText.bbcode_text = "WPM: " + str(finalWPM)
	$BeansEatenText.bbcode_text = "Beans Eaten: " + str(beansEaten)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setWPM(wpm: int):
	finalWPM = wpm
	print("WPM: ", finalWPM)

func setBeansEaten(killCount: int):
	beansEaten = killCount
	print("beans eaten: ", beansEaten)
