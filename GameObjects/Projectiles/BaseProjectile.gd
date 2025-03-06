extends CharacterBody2D
class_name BaseProjectile

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.05

@onready var hitbox_component:HitboxComponent = $HitboxComponent

var target:BaseEnemy

func _ready():
	hitbox_component.hit.connect(on_hitbox_hit)

func initialize(speed:float, direction:Vector2, _target:BaseEnemy):
	velocity = speed * direction
	target = _target

func on_hitbox_hit():
	destroy()

func _process(delta):
	rotation = (-velocity).angle()

func _physics_process(delta):
	velocity.y += gravity*delta
	if target != null && !target.is_dead:
		target_homing()
	fly_forward(delta)

func target_homing():
	var velocity_dir = velocity.normalized()
	var dir_to_target = position.direction_to(target.position)
	velocity_dir = velocity_dir.lerp(dir_to_target, 0.12)
	velocity = velocity.length() * velocity_dir

func fly_forward(delta):
	var collision : KinematicCollision2D = move_and_collide(velocity*delta)
	if collision:
		destroy()

func destroy():
	queue_free()
