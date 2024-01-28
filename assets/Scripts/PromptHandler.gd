extends Node2D
class_name PromptHandler

signal promptDoneSignal
signal beanSelected

@export var green = Color("#63f565")
@export var red = Color("#a63537")

@onready var promptLabel: RichTextLabel = $RichTextLabel
@onready var promptText: String
@onready var promptArray: Array
@onready var curIndex: int = 0
@onready var isDone: bool = false
@onready var signalBus = get_node("/root/SignalBus")

var promptIndex = 0
var prompts: Array = ["Default Prompt"]

var isSelected = false
var anySelected = false

# TODO:
# Stretch goals if we want to have multiple beans on screen
# 1. Begin implementing flags so each prompt manager
# will know whether there are active queries (has a letter been matched in any prompt)
# by listening to the game manager so letters typed in the middle of a prompt will
# not trigger the first letter in another prompt to be considered as typed
# 2. Add flag to only change incorrect letters to red if it is an active query
# so that every other prompt doesn't flash a red letter when typing the first letter
# for the desired prompt
# 3. Once a query in the active queries has been completed, the others should have
# colors and progress reset
# 4. Block repeated key-presses while key is pressed (wait until the key is released)

# Called when the node enters the scene tree for the first time.
func _ready():
	setCurrentPrompt()
	signalBus.beanSelectedSignal.connect(_on_bean_selected)
	signalBus.beanPromptDoneSignal.connect(_on_bean_prompt_done)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var letterTyped = OS.get_keycode_string(event.unicode)
		#print("Letter typed: ", letterTyped)
		checkChar(letterTyped)

func setCurrentPrompt():
	promptText = prompts[promptIndex]
	promptArray = convertPromptTextToArray(promptText)
	promptLabel.parse_bbcode(centerString(promptText))
	curIndex = 0

func convertPromptTextToArray(prompt: String):
	var promptArray: Array
	for char in prompt:
		match char:
			" ":
				promptArray.append("Space")
			".":
				promptArray.append("Period")
			"!":
				promptArray.append("Exclam")
			"-":
				promptArray.append("Minus")
			"'":
				promptArray.append("Apostrophe")
			_:
				promptArray.append(char)
	#print("Prompt array: ", promptArray)
	return promptArray

func checkChar(letter: String):
	if (!isDone and (isSelected or !anySelected)):
		# Correct letter
		# print("check char")
		if (letter == promptArray.front()):
			signalBus.beanSelectedSignal.emit(get_parent())
			promptArray.pop_front()
			setLabelCorrectCharsGreen()
			if (promptArray.size() == 0):
				completePhrase()
				#print("Prompt finished")
			else:
				curIndex += 1
		# Incorrect letter
		else:
			if (letter != ""):
				setLabelNextCharRed()
		
func completePhrase():
	promptIndex = promptIndex + 1
	if promptIndex >= len(prompts):
		isDone = true
		promptDoneSignal.emit()
		return
	setCurrentPrompt()
		
func setLabelCorrectCharsGreen():
	promptLabel.parse_bbcode(
		centerString(
			colorChar(promptText.substr(0, curIndex+1), green) + 
			promptText.substr(curIndex+1, promptText.length())
		)
	)
	
func setLabelNextCharRed():
	promptLabel.parse_bbcode(
		centerString(
			colorChar(promptText.substr(0, curIndex), green) + 
			colorChar(promptText[curIndex], red) + 
			promptText.substr(curIndex+1, promptText.length())
		)
	)
	
func colorChar(chars: String, color: Color) -> String:
	# print ("String to color: ", chars)
	return "[color=" + color.to_html(false) + "]" + chars + "[/color]"

func resetLabelColors():
	pass

func centerString(stringIn: String):
	return ("[center]" + stringIn + "[/center]")
	
func _on_bean_selected(beanInstance):
	#print("here")
	#print("bean selected: ", beanInstance.get_name())
	#print("current parent: ", get_parent().get_name())
	if beanInstance.get_name() == get_parent().get_name():
		isSelected = true
		#print("selected")
	anySelected = true

func _on_bean_prompt_done(beanInstance):
	isSelected = false
	anySelected = false
