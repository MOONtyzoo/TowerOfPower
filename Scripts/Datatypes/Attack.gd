# This is mainly used to bundle together information associated with being hit by an attack,
# such as damage, attack position, and knockback. This information will be sent to a hitbox
# when a hit has been detected and will be used to alter other properties like the health component.
extends RefCounted
class_name AttackData

var damage : int = 0
var knockback : float = 0
var movement_stun : float = 0
var position : Vector2 = Vector2.ZERO
var id : String

func instantiate(new_id:String, new_damage:int, new_knockback:float, new_movement_stun:float, new_position:Vector2) -> AttackData:
	id = new_id
	damage = new_damage
	position = new_position
	knockback = new_knockback
	movement_stun = new_movement_stun
	return self
