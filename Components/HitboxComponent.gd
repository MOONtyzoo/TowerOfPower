# Is responsible for detecting collisions with hurtboxes and activating a “hit” on them.
extends Area2D
class_name HitboxComponent

@export var id : String
@export var damage : int = 0
@export var knockback : float = 0
@export var movement_stun : float = 0
@export var frame_freeze : float = 0.0 #Duration of said freezeframe. SLowdown amount is in effects camera
# If defined, this will be used as the attacks origin. If not then it will be the center of the hurtbox
@export var position_override : Node2D
@export var start_active : bool = false

@export var hit_effect : PackedScene

var frame_num : int = 1

# Fired the instant that an attack goes off to tell if a melee hit or miss
signal melee_hit
signal melee_miss

signal hit

func _ready():
	deactivate()
	if start_active: activate()
	area_shape_entered.connect(on_area_shape_entered)

func _physics_process(delta):
	if monitoring:
		if frame_num == 2:
			var previous_pos = global_position
			if has_overlapping_areas():
				melee_hit.emit()
			else:
				melee_miss.emit()
		frame_num += 1

func activate():
	monitoring = true
	frame_num = 1

func deactivate():
	monitoring = false

# https://www.reddit.com/r/godot/comments/emnpwk/is_there_a_way_to_get_the_collision_position_from/
func on_area_shape_entered(area_id : RID, area : Area2D, area_shape_index : int, local_shape_index : int):
	if area is HurtboxComponent:
		var hurtbox : HurtboxComponent = area
		var attack_origin = global_position if !position_override else position_override.global_position
		var attack_data : AttackData = AttackData.new().instantiate(id, damage, knockback, movement_stun, attack_origin)
		hurtbox.handle_damage(attack_data)
		hit.emit()
		
		var is_projectile = area.get_collision_layer_value(4) || area.get_collision_layer_value(5)
		if hit_effect && !is_projectile:
			spawn_hit_effect(get_area_collision_point(area_id, area, area_shape_index, local_shape_index))
			Globals.camera.frame_freeze(frame_freeze)

func get_area_collision_point(area_id : RID, area : Area2D, area_shape_index : int, local_shape_index : int) -> Vector2:
	var other_shape_owner_id = area.shape_find_owner(area_shape_index)
	var other_shape_owner = area.shape_owner_get_owner(other_shape_owner_id)
	var other_shape_2d = area.shape_owner_get_shape(other_shape_owner_id, 0)
	var other_global_transform = other_shape_owner.global_transform
	
	var local_shape_owner_id = shape_find_owner(area_shape_index)
	var local_shape_owner = shape_owner_get_owner(local_shape_owner_id)
	var local_shape_2d = shape_owner_get_shape(local_shape_owner_id, 0)
	var local_global_transform = local_shape_owner.global_transform
	
	var collision_points : PackedVector2Array = local_shape_2d.collide_and_get_contacts(local_global_transform, other_shape_2d, other_global_transform)
	
	if collision_points.size() > 0:
		return collision_points[0]
	else:
		return Vector2.ONE*10000

func spawn_hit_effect(position:Vector2):
	var effect : Node2D = hit_effect.instantiate()
	effect.global_position = position
	get_tree().get_root().add_child(effect)
