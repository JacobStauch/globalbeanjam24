extends Node

@onready var dialoguePath = "res://assets/Text/dialogue.json"
@onready var textSpeed = 0.05

signal dialogue_finished

var dialogue
var phraseNum = 0
var finished = false
#TODO: get currentState from game manager to show correct dialogue
var currentState = "start"
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Timer.wait_time = textSpeed
	dialogue = getDialogue()
	nextPhrase()

func getDialogue() -> Array:
	var file = FileAccess.open(dialoguePath, FileAccess.READ)
	var jsonContent = file.get_as_text()
	var json = JSON.new()
	var e = json.parse(jsonContent)
	if e != OK:
		print("Failed to load json: %s" % e)
		return []
	return json.data[currentState]


func nextPhrase() -> void:
	if phraseNum >= len(dialogue):
		queue_free()
		dialogue_finished.emit(currentState)
		return
	finished = false
	
	$Text.bbcode_text = "[color=black]" + dialogue[phraseNum]["text"]
	
	var img = "res://assets/Graphics/beanking" + "_" + dialogue[phraseNum]["emotion"] + ".png"
	$Portrait.texture = load(img)
	
	$Text.visible_characters = 0
	$Indicator/AnimationPlayer.stop()
	$Indicator.set_visible(false)
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	finished = true
	phraseNum += 1
	$Indicator.set_visible(true)
	$Indicator/AnimationPlayer.play("IndicatorAnimation")
	return
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)
