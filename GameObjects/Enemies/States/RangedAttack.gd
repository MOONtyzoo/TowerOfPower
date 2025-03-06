extends State

var enemy:BaseEnemy

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
	pass
