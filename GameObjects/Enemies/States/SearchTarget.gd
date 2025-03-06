extends State

@export var next_state:State

var enemy:BaseEnemy

# State machine provides all children with a reference to the controlled node
func initialize(base_node:Node2D):
	enemy = base_node

func enter():
	await get_tree().create_timer(0.1).timeout
	while enemy.target == null:
		if enemy.search_target():
			transitioned.emit(self, next_state.name)
			break
		await get_tree().create_timer(1.0).timeout

func exit():
	pass

func update(delta:float):
	pass

func physics_update(delta:float):
	pass
