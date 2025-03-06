extends Node2D
class_name State

signal transitioned

# State machine provides all children with a reference to the controlled node
func initialize(base_node:Node2D):
	pass

func enter():
	pass

func exit():
	pass

func update(delta:float):
	pass

func physics_update(delta:float):
	pass
