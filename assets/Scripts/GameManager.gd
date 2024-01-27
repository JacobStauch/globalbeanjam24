extends Node2D

@onready var signalBus = get_node("/root/SignalBus")
@onready var beanObjectScene: PackedScene = preload("res://assets/Scenes/Objects/BasicBean.tscn")
@onready var beanLevelJsonFile = FileAccess.open("res://assets/Text/level_beans.json", FileAccess.READ)
@onready var beanPhraseJsonFile = FileAccess.open("res://assets/Text/bean_phrases.json", FileAccess.READ)
@onready var beanSpriteJsonFile = FileAccess.open("res://assets/Text/bean_sprites.json", FileAccess.READ)
@onready var beanSpeedJsonFile = FileAccess.open("res://assets/Text/bean_speeds.json", FileAccess.READ)
@onready var beanLevelJson: Dictionary = JSON.parse_string(beanLevelJsonFile.get_as_text())
@onready var beanPhraseJson: Dictionary = JSON.parse_string(beanPhraseJsonFile.get_as_text())
@onready var beanSpriteJson: Dictionary = JSON.parse_string(beanSpriteJsonFile.get_as_text())
@onready var beanSpeedJson: Dictionary = JSON.parse_string(beanSpeedJsonFile.get_as_text())
@onready var healthHUD = $HealthBeans

@onready var levels = ["kingdom", "castle", "chamber"]
@onready var curLevelIndex = 0
@onready var curLevel = levels[curLevelIndex]

@onready var levelDurations = [10, 20, 30]
@onready var curLevelDuration = 0
@onready var levelStopwatch := 0.0

@onready var levelInProgress: bool = false

@onready var path_manager = get_tree().get_first_node_in_group("PathManagers")

signal new_bean_created

var beansKilled = 0
var maxBeanCount = 3
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	# Seed RNG
	randomize()
	# Connect signals
	signalBus.beanPromptDoneSignal.connect(_on_bean_prompt_done)
	signalBus.dialogueBoxFinishedSignal.connect(_on_dialogue_box_finished)
	signalBus.beanAtEndSignal.connect(_on_hit)
	# Create BeanContainer child node to hold all the Bean objects
	var beanContainerNode = Node2D.new()
	beanContainerNode.name = "BeanContainer"
	self.add_child(beanContainerNode)
	
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
	beanInstance.queue_free()
	beansKilled += 1
	print("Beans Killed: ", beansKilled)
	
	createBean(curLevel)

func _on_hit(beanInstance):
	health = health - 1
	healthHUD.update_health(health)
	beanInstance.queue_free()
	createBean(curLevel)

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
	beanMovementScript.set_path(path_manager.get_random_path("kingdom"+str(randi_range(0,2))))
	
	var beanMovementTimer = beanMovementScript.get_node("MovementTimer") as Timer
	beanMovementTimer.wait_time = getRandomTime(randomBeanTypeFromLevel)
	
	$BeanContainer.add_child(beanObject)
	emit_signal("new_bean_created")
	
func despawnAllBeans():
	for c in $BeanContainer.get_children():
		c.queue_free()

func startCurLevel():
	levelInProgress = true
	curLevelDuration = levelDurations[curLevelIndex]
	createBean(curLevel)

func finishCurLevel():
	despawnAllBeans()
	curLevelIndex += 1
	refreshCurLevelVars()
	levelInProgress = false
	# immediately start next level for testing purposes
	startCurLevel()
	
func refreshCurLevelVars():
	curLevel = levels[curLevelIndex]
	curLevelDuration = levelDurations[curLevelIndex]
	levelStopwatch = 0.0

func getRandomTime(beanType):
	var beanTimes = beanSpeedJson[beanType]
	return randf_range(beanTimes["min"], beanTimes["max"])
