extends Node2D

@onready var signalBus = get_node("/root/SignalBus")
@onready var beanObjectScene: PackedScene = preload("res://assets/Scenes/Objects/BasicBean.tscn")
@onready var beanLevelJsonFile = FileAccess.open("res://assets/Text/level_beans.json", FileAccess.READ)
@onready var beanPhraseJsonFile = FileAccess.open("res://assets/Text/bean_phrases.json", FileAccess.READ)
@onready var beanSpriteJsonFile = FileAccess.open("res://assets/Text/bean_sprites.json", FileAccess.READ)
@onready var beanLevelJson: Dictionary = JSON.parse_string(beanLevelJsonFile.get_as_text())
@onready var beanPhraseJson: Dictionary = JSON.parse_string(beanPhraseJsonFile.get_as_text())
@onready var beanSpriteJson: Dictionary = JSON.parse_string(beanSpriteJsonFile.get_as_text())
@onready var healthHUD = $HealthBeans

@onready var curLevel = "kingdom"

@onready var path_manager = get_tree().get_first_node_in_group("PathManagers")

signal new_bean_created

var beansKilled = 0
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	# Seed RNG
	randomize()
	# Connect signals
	signalBus.beanPromptDoneSignal.connect(_on_bean_prompt_done)
	signalBus.dialogueBoxFinishedSignal.connect(_on_dialogue_box_finished)
	path_manager.current_level = curLevel
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_dialogue_box_finished():
	print("Game Manager acknowledges dialogue box finished")
	createBean(curLevel)

func _on_bean_prompt_done(beanInstance):
	print("Prompt done signal received")
	print("Found Node from signal: ", beanInstance.get_name())
	print("Deleting bean")
	beanInstance.queue_free()
	beansKilled += 1
	print("Beans Killed: ", beansKilled)

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
	beanMovementScript.set_path(path_manager.get_random_path())
	
	add_child(beanObject)
	emit_signal("new_bean_created")

func on_hit():
	health = health - 1
	healthHUD.update_health(health)
