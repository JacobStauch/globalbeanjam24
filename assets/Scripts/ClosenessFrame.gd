extends Node2D

var elapsedTime: float = 0.0
var changeTime: float = 4.0

var points: Array[Node] = []
var currentPointIndex: int = 0

signal updatePosition(newTransform: Transform2D)

func _ready():
	points = $MovementPoints.get_children()
	print(points[0].transform)

func _process(delta):
	elapsedTime += delta
	
	if elapsedTime >= changeTime:
		elapsedTime = 0.0
		print("Jump ahead")
	
	$MovementPoints/Timer.wait_time = 4
