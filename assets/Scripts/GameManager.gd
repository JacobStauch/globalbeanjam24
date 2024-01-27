extends Node2D

#Get Signal Bus node
@onready var signalBus = get_node("/root/SignalBus")
#Preload Object scenes
@onready var beanObjectScene: PackedScene = preload("res://assets/Scenes/Objects/BasicBean.tscn")
@onready var beanHudScene: PackedScene = preload("res://assets/Scenes/Objects/HealthBeans.tscn")
@onready var endMenuScene: PackedScene = preload("res://assets/Scenes/Objects/EndMenu.tscn")
#Preload JSON files
@onready var beanLevelJsonFile = FileAccess.open("res://assets/Text/level_beans.json", FileAccess.READ)
@onready var beanPhraseJsonFile = FileAccess.open("res://assets/Text/bean_phrases.json", FileAccess.READ)
@onready var beanSpriteJsonFile = FileAccess.open("res://assets/Text/bean_sprites.json", FileAccess.READ)
@onready var beanSpeedJsonFile = FileAccess.open("res://assets/Text/bean_speeds.json", FileAccess.READ)
# Create parsed JSON vars
@onready var beanLevelJson: Dictionary = JSON.parse_string(beanLevelJsonFile.get_as_text())
@onready var beanPhraseJson: Dictionary = JSON.parse_string(beanPhraseJsonFile.get_as_text())
@onready var beanSpriteJson: Dictionary = JSON.parse_string(beanSpriteJsonFile.get_as_text())
@onready var beanSpeedJson: Dictionary = JSON.parse_string(beanSpeedJsonFile.get_as_text())

# Initialize HUD reference
@onready var healthHUD
# Create Level Progression vars
@onready var levels = ["kingdom", "castle", "chamber"]
@onready var curLevelIndex = 0
@onready var curLevel = levels[curLevelIndex]

#Create level timer vars
@onready var levelDurations = [10, 20, 30]
@onready var curLevelDuration = 0
@onready var levelStopwatch := 0.0

# Create level flags
@onready var levelInProgress: bool = false

# Get reference to PathManager node
@onready var path_manager = get_tree().get_first_node_in_group("PathManagers")

# Create Game Manager signals
signal new_bean_created

# Create stat tracking vars
var beansKilled = 0
var maxBeanCount = 1
var health = 3
var freePaths = [0,1,2] 
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
	
	path_manager.current_level = curLevel
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (levelInProgress):
		levelStopwatch += delta
		if (levelStopwatch > curLevelDuration):
			finishCurLevel()

func _on_dialogue_box_finished():
	print("Game Manager acknowledges dialogue box finished")
	startCurLevel()

func _on_bean_prompt_done(beanInstance):
	print("Prompt done signal received")
	print("Found Node from signal: ", beanInstance.get_name())
	print("Deleting bean")
	switch_path_locked(beanInstance.get_bean_path_num(), true)
	updateCharsTyped(beanInstance)
	beanInstance.queue_free()
	beansKilled += 1
	print("Beans Killed: ", beansKilled)
	var randomBeanCount = randi_range(1,maxBeanCount)
	for i in randomBeanCount:
		if freePaths.size() > 0:
			createBean(curLevel)

func _on_hit(beanInstance):
	health = health - 1
	healthHUD.update_health(health)
	switch_path_locked(beanInstance.get_bean_path_num(), true)
	updateCharsTyped(beanInstance)
	beanInstance.queue_free()
	var randomBeanCount = randi_range(1,maxBeanCount)
	for i in randomBeanCount:
		if freePaths.size() > 0: #create bean if there is a free path
			createBean(curLevel)

func updateCharsTyped(beanInstance):
	var promptHandler = beanInstance.get_node("PromptHandler")
	var charsTyped = promptHandler.getCharsTyped()
	var errorsTyped = promptHandler.getErrorsTyped()
	totalCharsTyped += charsTyped
	totalErrorsTyped += errorsTyped

func createBean(level: String):
	var numBeanTypesInLevel = beanLevelJson[level].size()-1
	var randomBeanTypeFromLevel = beanLevelJson[level][randi_range(0,numBeanTypesInLevel)]
	
	var numPhrasesForBeanType = beanPhraseJson[randomBeanTypeFromLevel].size()-1
	var randomBeanPhrase = beanPhraseJson[randomBeanTypeFromLevel][randi_range(0,numPhrasesForBeanType)]
	
	var beanObject = beanObjectScene.instantiate()
	
	var beanSprite: Sprite2D = beanObject.get_node("BasicBeanSprite")
	beanSprite.texture = load(beanSpriteJson[randomBeanTypeFromLevel])
	
	var beanPromptHandler = beanObject.get_node("PromptHandler")
	var beanPromptLabel: RichTextLabel = beanPromptHandler.get_node("RichTextLabel")
	beanPromptLabel.text = randomBeanPhrase
	
	var beanMovementScript = beanObject.get_node("MovementControl")
	var randomPathIndex = randi_range(0,freePaths.size()-1)
	var randomPath = freePaths[randomPathIndex]
	beanMovementScript.set_path(path_manager.get_random_path("kingdom"+str(randomPath)), randomPath)
	
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
	maxBeanCount = curLevelIndex + 1
	var randomBeanCount = randi_range(1,maxBeanCount)
	print(randomBeanCount)
	for i in randomBeanCount:
		if freePaths.size() > 0:
			createBean(curLevel)

func finishCurLevel():
	despawnAllBeans()
	curLevelIndex += 1
	totalTimeInSeconds += levelStopwatch
	print("total time: ", totalTimeInSeconds)
	print("total chars typed: ", totalCharsTyped)
	print("total errors typed: ", totalErrorsTyped)
	levelInProgress = false
	# immediately start next level for testing purposes
	if curLevelIndex < 3:
		refreshCurLevelVars()
		startCurLevel()
	else:
		get_tree().paused = true
		var endMenu = endMenuScene.instantiate()
		var panel = endMenu.get_node("CenterContainer/BackgroundPanel")
		var wpm = (totalCharsTyped - totalErrorsTyped)/((totalTimeInSeconds/60) * 5)
		panel.setWPM(wpm)
		panel.setBeansEaten(beansKilled)
		add_sibling(endMenu)
	
func refreshCurLevelVars():
	curLevel = levels[curLevelIndex]
	curLevelDuration = levelDurations[curLevelIndex]
	levelStopwatch = 0.0
	freePaths = [0,1,2]
	print("paths reset")

func getRandomTime(beanType):
	var beanTimes = beanSpeedJson[beanType]
	return randf_range(beanTimes["min"], beanTimes["max"])

func switch_path_locked(beanPath, destroyed):
	print("beanPath: ", beanPath)
	print("freePaths1: ", freePaths)
	for i in freePaths.size():
		if freePaths[i] == beanPath:
			print("here")
			freePaths.remove_at(i)
			break
	if destroyed:
		freePaths.append(beanPath)
	print("freePaths2: ", freePaths)

func _on_bean_created_signal(beanInstance):
	var beanPathNum = beanInstance.get_bean_path_num()
	switch_path_locked(beanPathNum, false)
	print("bean path: ", beanPathNum)
