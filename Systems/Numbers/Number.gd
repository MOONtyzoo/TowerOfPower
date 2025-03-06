extends Node2D
class_name Number

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize(number:int, number_type:int):
	$Sprite2D.frame_coords = Vector2(number, number_type)
