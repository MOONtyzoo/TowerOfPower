extends Sprite2D
class_name PurchaseTab

var cost:int = 0

var initial_position:Vector2
@export var jump_height:float = 4 # The amount the label jumps up when appearing
@export var hover_amplitude:float = 2
@export var hover_frequency:float = 0.5

var base_position:Vector2

var is_focused:bool = false
@export var unfocused_transparency:float = 0.8

@onready var cost_label:Label = $CostLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = position
	base_position = initial_position
	material.set_shader_parameter("transparency", unfocused_transparency)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hover_offset(delta)

func focus():
	if is_focused == true: return
	is_focused = true
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "base_position", initial_position+Vector2.UP*jump_height, 0.25)
	tween.tween_method(func(value:float):
		material.set_shader_parameter("transparency", value)
		, unfocused_transparency, 0.0, 0.25)

func unfocus():
	if is_focused == false: return
	is_focused = false
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "base_position", initial_position, 0.25)
	tween.tween_method(func(value:float):
		material.set_shader_parameter("transparency", value)
		, 0.0, unfocused_transparency, 0.25)

func set_cost(new_cost:int):
	cost = new_cost
	cost_label.text = str(cost)

var timer:float = 0
func hover_offset(delta):
	timer += delta
	if !is_focused: timer = 0
	var hover_offset:float = hover_amplitude*cos(2*PI*hover_frequency*timer)
	position = base_position + Vector2.UP*hover_offset
