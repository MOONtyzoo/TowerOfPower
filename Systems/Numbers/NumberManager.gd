extends Node2D
class_name NumberManager

var number_scene : PackedScene = preload("res://Systems/Numbers/Number.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

enum number_type{white, green, red}
func spawn_number(number:int, type:number_type, position:Vector2):
	var number_node : Number = number_scene.instantiate()
	number_node.initialize(number, type)
	number_node.position = position
	add_child(number_node)
