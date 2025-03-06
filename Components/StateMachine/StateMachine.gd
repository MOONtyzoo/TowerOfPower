extends Node2D
class_name StateMachine

@export var base_node : Node
@export var initial_state : State

@export var debug_mode : bool = false

var current_state : State
var states : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			child.initialize(base_node)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(old_state:State, new_state_name:String):
	if old_state != current_state:
		return
	
	var new_state : State = states[new_state_name.to_lower()]
	if new_state == null:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
	
	if debug_mode: print("Transition from " + old_state.name + " to " + new_state.name)
