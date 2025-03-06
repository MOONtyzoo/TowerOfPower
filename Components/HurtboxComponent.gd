# Has a collision but only exists to be detected by the hurtbox and to handle any “hits”.
# For example, it will delegate the attack information to the health component if it exists.
extends Area2D
class_name HurtboxComponent

@export var health_component : HealthComponent

signal hit(attack : AttackData)

func handle_damage(attack : AttackData):
	if health_component:
		health_component.take_damage(attack)
	hit.emit(attack)
