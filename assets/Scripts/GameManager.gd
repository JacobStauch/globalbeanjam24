extends Node2D

#Get Signal Bus node
@onready var signalBus = get_node("/root/SignalBus")
#Preload Object scenes
@onready var beanObjectScene: PackedScene = preload("res://assets/Scenes/Objects/BasicBean.tscn")
@onready var beanHudScene: PackedScene = preload("res://assets/Scenes/Objects/HealthBeans.tscn")
@onready var beanDialogueBoxScene: PackedScene = preload("res://assets/Scenes/Objects/DialogueBox.tscn")
@onready var levelTransitionScene: PackedScene = preload("res://assets/Scenes/Objects/LevelTransitionText.tscn")
#Preload JSON files
@onready var beanLevelJsonFile = FileAccess.open("res://assets/Text/level_beans.json", FileAccess.READ)
@onready var beanPhraseJsonFile = FileAccess.open("res://assets/Text/bean_phrases.json", FileAccess.READ)
@onready var beanSpriteJsonFile = FileAccess.open("res://assets/Text/bean_sprites.json", FileAccess.READ)
@onready var beanSpeedJsonFile = FileAccess.open("res://assets/Text/bean_speeds.json", FileAccess.READ)
@onready var bossPhrasesJsonFile = FileAccess.open("res://assets/Text/boss_phrases.json", FileAccess.READ)
@onready var levelSpritesJsonFile = FileAccess.open("res://assets/Text/level_sprites.json", FileAccess.READ)
@onready var levelNamesJsonFile = FileAccess.open("res://assets/Text/level_names.json", FileAccess.READ)
# Create parsed JSON vars
@onready var beanLevelJson: Dictionary = JSON.parse_string(beanLevelJsonFile.get_as_text())
@onready var beanPhraseJson: Dictionary = JSON.parse_string(beanPhraseJsonFile.get_as_text())
@onready var beanSpriteJson: Dictionary = JSON.parse_string(beanSpriteJsonFile.get_as_text())
@onready var beanSpeedJson: Dictionary = JSON.parse_string(beanSpeedJsonFile.get_as_text())
@onready var bossPhrasesJson: Array = JSON.parse_string(bossPhrasesJsonFile.get_as_text())
@onready var levelSpritesJson: Dictionary = JSON.parse_string(levelSpritesJsonFile.get_as_text())
@onready var levelNamesJson: Dictionary = JSON.parse_string(levelNamesJsonFile.get_as_text())

# Initialize HUD reference
@onready var healthHUD
# Create Level Progression vars
@onready var levels = ["kingdom", "castle", "chamber"]
@onready var curLevelIndex = 0
@onready var curLevel = levels[curLevelIndex]

#Create level timer vars
@onready var levelDurations = [40, 40, 30]
@onready var curLevelDuration = 0
@onready var levelStopwatch := 0.0

# Create level flags
@onready var levelInProgress: bool = false

# Get reference to PathManager node
@onready var path_manager = get_tree().get_first_node_in_group("PathManagers")

# Get reference to Camera node
@onready var camera = get_viewport().get_camera_2d()

# Get reference to Background node
@onready var bg: Panel = get_node("../Background")

# Get reference to audio player
@onready var music: AudioStreamPlayer2D = get_node("../BackgroundMusic")

# Create Game Manager signals
signal new_bean_created

# Create stat tracking vars
var beansKilled = 0
var maxBeanCount = 1
var health = 3
var freePaths = [0,1,2]
var dialogue_in_progress = false

@onready var bossPhrasesUsed = get_random_boss_phrases()

var totalTimeInSeconds = 0.0
var totalCharsTyped = 0
var totalErrorsTyped = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Seed RNG
	randomize()
	# Connect signals
	signalBus.beanPromptDoneSignal.connect(_on_bean_prompt_done)
	signalBus.dialogueBoxFinishedSignal.connect(_on_dialogue_box_finished)
	signalBus.beanAtEndSignal.connect(_on_hit)
	signalBus.beanCreatedSignal.connect(_on_bean_created_signal)
	signalBus.levelTransitionFinished.connect(_on_level_transition_finished)
	# Create BeanContainer child node to hold all the Bean objects
	var beanContainerNode = Node2D.new()
	beanContainerNode.name = "BeanContainer"
	self.add_child(beanContainerNode)
	# Create player health HUD
	var healthHudNode = beanHudScene.instantiate()
	healthHudNode.name = "HealthBeans"
	healthHudNode.hide()
	self.add_child(healthHudNode)
	healthHUD = $HealthBeans
	# Set current level for PathManager
	path_manager.current_level = curLevel
	# Initiate intro dialogue
	startDialogue("start")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (levelInProgress && curLevelIndex != len(levels) - 1):
		levelStopwatch += delta
		if (levelStopwatch > curLevelDuration):
			finishCurLevel()

func _on_dialogue_box_finished(currentState):
	print("Game Manager acknowledges dialogue box finished")
	print("Dialogue state finished: ", currentState)
	$DialogueBoxContainer.queue_free()

	if currentState in levels or currentState == "start":
		healthHUD.show()
		doLevelTransition()
	else:
		music.stream = load("res://assets/Music/stats.mp3")
		music.play()
		
		var endMenu = get_node("../EndMenu")
		var panel = endMenu.get_node("CenterContainer/BackgroundPanel")
		var wpm = (totalCharsTyped - totalErrorsTyped)/((totalTimeInSeconds/60) * 5)
		panel.setWPM(wpm)
		panel.setBeansEaten(beansKilled)
		endMenu.show()
		endMenu.auto_select_option()

func _on_bean_prompt_done(beanInstance):
	print("Prompt done signal received")
	print("Found Node from signal: ", beanInstance.get_name())
	switch_path_locked(beanInstance.get_bean_path_num(), true)
	updateCharsTyped(beanInstance)
	beansKilled += 1
	if curLevelIndex == len(levels) - 1:
		finishGameGoodEnd()
		return
	#print("Beans Killed: ", beansKilled)
	var randomBeanCount = randi_range(1,maxBeanCount)
	for i in randomBeanCount:
		if freePaths.size() > 0 and 3 - freePaths.size() < maxBeanCount:
			createBean(curLevel)
		await get_tree().create_timer(1.5).timeout

func _on_hit(beanInstance):
	health = health - 1
	healthHUD.update_health(health)
	camera.apply_shake()
	$SoundEffects.play()
	switch_path_locked(beanInstance.get_bean_path_num(), true)
	updateCharsTyped(beanInstance)
	if !beanInstance.isBoss:
		beanInstance.queue_free()
	if (health == 0):
		finishGameBadEnd()
	elif !beanInstance.isBoss:
		var randomBeanCount = randi_range(1,maxBeanCount)
		for i in randomBeanCount:
			if freePaths.size() > 0 and 3 - freePaths.size() < maxBeanCount: #create bean if there is a free path
				createBean(curLevel)
			await get_tree().create_timer(1.5).timeout

func _on_bean_created_signal(beanInstance):
	var beanPathNum = beanInstance.get_bean_path_num()
	switch_path_locked(beanPathNum, false)
	print("bean path: ", beanPathNum)
	
func _on_level_transition_finished():
	print("Received level transition finished signal, starting level")
	startCurLevel()

func updateCharsTyped(beanInstance):
	var promptHandler = beanInstance.get_node("PromptHandler")
	var charsTyped = promptHandler.getCharsTyped()
	var errorsTyped = promptHandler.getErrorsTyped()
	totalCharsTyped += charsTyped
	totalErrorsTyped += errorsTyped

func createBean(level: String, isLastLevel: bool = false):
	if (levelInProgress):
		var numBeanTypesInLevel = beanLevelJson[level].size()-1
		var randomBeanTypeFromLevel = beanLevelJson[level][randi_range(0,numBeanTypesInLevel)]
		
		var numPhrasesForBeanType = beanPhraseJson[randomBeanTypeFromLevel].size()-1
		var randomBeanPhrase = beanPhraseJson[randomBeanTypeFromLevel][randi_range(0,numPhrasesForBeanType)]
		
		var beanObject = beanObjectScene.instantiate() as BeanScript
		beanObject.isBoss = isLastLevel
		
		var beanSprite: AnimatedSprite2D = beanObject.get_node("BasicBeanSprite")
		beanSprite.set_animation(beanSpriteJson[randomBeanTypeFromLevel])
		beanSprite.play()
		
		var beanPromptHandler = beanObject.get_node("PromptHandler") as PromptHandler
		
		if !isLastLevel:
			beanPromptHandler.prompts = [randomBeanPhrase] as Array[String]
		else:
			beanPromptHandler.prompts = bossPhrasesUsed
		
		var beanMovementScript = beanObject.get_node("MovementControl")
		var randomPathIndex = randi_range(0,freePaths.size()-1)
		var randomPath = freePaths[randomPathIndex]
		beanMovementScript.set_path(path_manager.get_random_path(curLevel+str(randomPath)), randomPath)
		
		var beanMovementTimer = beanMovementScript.get_node("MovementTimer") as Timer
		beanMovementTimer.wait_time = getRandomTime(randomBeanTypeFromLevel)
		
		$BeanContainer.add_child(beanObject)
		emit_signal("new_bean_created")
		SignalBus.beanCreatedSignal.emit(beanObject)
	
func despawnAllBeans():
	for c in $BeanContainer.get_children():
		c.queue_free()

func startCurLevel():
	levelInProgress = true
	curLevelDuration = levelDurations[curLevelIndex]
	maxBeanCount += 1
	var randomBeanCount = randi_range(1,maxBeanCount)
	
	var isLastLevel = curLevelIndex == len(levels) - 1
	if isLastLevel: # Force there to only be one bean in the last level (the boss bean)
		music.stream = load("res://assets/Music/boss.mp3")
		music.play()
		randomBeanCount = 1
		
	#print(randomBeanCount)
	for i in randomBeanCount:
		if freePaths.size() > 0 and 3 - freePaths.size() < maxBeanCount:
			createBean(curLevel, isLastLevel)
		await get_tree().create_timer(1.5).timeout

func finishCurLevel():
	levelInProgress = false
	print("Done with level")
	despawnAllBeans()
	curLevelIndex += 1
	
	totalTimeInSeconds += levelStopwatch
	print("total time: ", totalTimeInSeconds)
	
	if (levels.size() == curLevelIndex):
		finishGameGoodEnd()
	else:
		startLevelDialogue(levels[curLevelIndex])
		refreshCurLevelVars()
	
func refreshCurLevelVars():
	curLevel = levels[curLevelIndex]
	curLevelDuration = levelDurations[curLevelIndex]
	levelStopwatch = 0.0
	freePaths = [0,1,2]
	#print("paths reset")

func getRandomTime(beanType):
	var beanTimes = beanSpeedJson[beanType]
	return randf_range(beanTimes["min"], beanTimes["max"])

func switch_path_locked(beanPath, destroyed):
	#print("beanPath: ", beanPath)
	#print("freePaths1: ", freePaths)
	for i in freePaths.size():
		if freePaths[i] == beanPath:
			#print("here")
			freePaths.remove_at(i)
			break
	if destroyed:
		freePaths.append(beanPath)
	#print("freePaths2: ", freePaths)

func get_random_boss_phrases():
	var random_phrases = bossPhrasesJson.duplicate()
	random_phrases.shuffle()
	var to_use = []
	for i in 3:
		to_use.append(random_phrases[0])
		random_phrases.pop_front()
	return to_use

func startDialogue(state: String):
	dialogue_in_progress = true
	signalBus.dialogueStartedSignal.emit()
	var dialogueBoxContainerNode = beanDialogueBoxScene.instantiate()
	dialogueBoxContainerNode.name = "DialogueBoxContainer"
	healthHUD.hide()
	var dialogueBoxNode = dialogueBoxContainerNode.get_node("DialogueBox")
	dialogueBoxNode.setDialogue(state)
	
	self.add_child(dialogueBoxContainerNode)

func finishGameGoodEnd():
	healthHUD.hide()
	startDialogue("ending_good")
	
func finishGameBadEnd():
	despawnAllBeans()
	startDialogue("ending_bad")
	
func startLevelDialogue(currentLevel: String):
	healthHUD.hide()
	startDialogue(currentLevel)
	
func doLevelTransition():
	bg.get_theme_stylebox("panel").texture = load(levelSpritesJson[curLevel])
	
	var levelTransitionTextObject = levelTransitionScene.instantiate()
	var levelTransitionTextLabel = levelTransitionTextObject.get_node("RichTextLabel")
	levelTransitionTextLabel.text = "[center]" + levelNamesJson[curLevel] + "[/center]"
	
	add_child(levelTransitionTextObject)
	
	var timer := Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	
func _on_timer_timeout():
	print("Timer timed out")
	signalBus.levelTransitionFinished.emit()
