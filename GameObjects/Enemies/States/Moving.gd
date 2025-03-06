extends State

var enemy:BaseEnemy
@export var attack_state:State

# State machine provides all children with a reference to the controlled node
func initialize(base_node:Node2D):
	enemy = base_node

func enter():
	pass

func exit():
	pass

func update(delta:float):
	pass

func physics_update(delta:float):	
	if !enemy.is_in_range_of_target():
		enemy.move_to_target(delta)
	else:
		if !enemy.is_flying:
			if enemy.is_on_floor(): transitioned.emit(self, attack_state.name)
		else:
			transitioned.emit(self, attack_state.name)
