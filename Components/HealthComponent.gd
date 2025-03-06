# Contains information about an entity’s health and allows for taking damage.
# Will signal when a hit occurs and when the health bar “dies”
# (actually dying is up for the implementation of the actual entity)
extends Node2D
class_name HealthComponent

@export var max_health : float
var current_health : float
var is_invulnerable : bool = false

@export var hit_numbers:bool = false
@export var hit_number_type:int = 0

signal health_changed
signal health_lost
signal health_gained
signal health_depleted

func _ready():
	current_health = max_health

func take_damage(attack : AttackData):
	if !is_invulnerable:
		current_health = max(current_health - attack.damage, 0)
		health_changed.emit()
		health_lost.emit()
		if current_health == 0: health_depleted.emit()
		Globals.number_manager.spawn_number(attack.damage, hit_number_type, global_position)

func print_health():
	print("Health: " + str(current_health) + "/" + str(max_health))
