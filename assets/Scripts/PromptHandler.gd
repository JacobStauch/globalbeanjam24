extends Node2D

signal promptDoneSignal

@export var green = Color("#63f565")
@export var red = Color("#a63537")

@onready var promptLabel: RichTextLabel = $RichTextLabel
@onready var promptText: String = promptLabel.text
@onready var promptArray: Array = convertPromptTextToArray(promptText)
@onready var curIndex: int = 0
@onready var isDone: bool = false

# TODO:
# 1. Handle typing one prompt (Done)
# 2. Change letter color based on correct or incorrect typing (Done)
# 3. Begin implementing flags so each prompt manager
# will know whether there are active queries (has a letter been matched in any prompt)
# by listening to the game manager so letters typed in the middle of a prompt will
# not trigger the first letter in another prompt to be considered as typed
# 4. Add flag to only change incorrect letters to red if it is an active query
# so that every other prompt doesn't flash a red letter when typing the first letter
# for the desired prompt
# 5. Once a query in the active queries has been completed, the others should have
# colors and progress reset
# 6. Block repeated key-presses while key is pressed (wait until the key is released)

# Called when the node enters the scene tree for the first time.
func _ready():
	promptLabel.parse_bbcode(centerString(promptText))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var letterTyped = OS.get_keycode_string(event.unicode)
		print("Letter typed: ", letterTyped)
		checkChar(letterTyped)

func convertPromptTextToArray(prompt: String):
	var promptArray: Array
	for char in prompt:
		if (char == " "):
			promptArray.append("Space")
		elif (char == "."):
			promptArray.append("Period")
		elif (char == "!"):
			promptArray.append("Exclam")
		else:
			promptArray.append(char)
	print("Prompt array: ", promptArray)
	return promptArray

func checkChar(letter: String):
	if (!isDone):
		# Correct letter
		# print("check char")
		if (letter == promptArray.front()):
			promptArray.pop_front()
			setLabelCorrectCharsGreen()
			if (promptArray.size() == 0):
				isDone = true
				promptDoneSignal.emit()
				print("Prompt finished")
			else:
				curIndex += 1
		# Incorrect letter
		else:
			if (letter != ""):
				setLabelNextCharRed()
		
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
