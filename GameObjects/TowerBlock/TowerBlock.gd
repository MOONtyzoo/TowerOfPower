extends CharacterBody2D
class_name TowerBlock

var tower:Tower
const blockDimensions:Vector2 = Vector2(64, 40)
var id:int = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_falling:bool = true

var upperBlockConnection:TowerBlock = null
var lowerBlockConnection:TowerBlock = null

@onready var sprite:Sprite2D = $Sprite2D
@onready var health_component:HealthComponent = $HealthComponent
@onready var health_bar:Sprite2D = $HealthBar
@onready var debug_label:Label = $DebugLabel

@onready var left_platform:TurretPlatform = $LeftTurretPlatform
@onready var right_platform:TurretPlatform = $RightTurretPlatform

@onready var placed_sound:AudioStreamPlayer2D = $Placed
@onready var hurt_sound:AudioStreamPlayer2D = $Hurt

signal destroyed

func _ready():
	update_debug_label()
	placed_sound.play()
	
	health_component.health_lost.connect(on_hit)
	health_component.health_changed.connect(on_health_changed)
	health_component.health_depleted.connect(destroy)

func _physics_process(delta):
	if is_falling:
		block_falling(delta)
	
	#if Input.is_action_just_pressed("rightClick"):
		#if $Sprite2D.get_rect().has_point($Sprite2D.to_local(get_global_mouse_position())):
			#destroy()

func block_falling(delta):
	velocity.y += gravity * delta

	var collision:KinematicCollision2D = move_and_collide(velocity*delta)
	if collision:
		if collision.get_collider().is_in_group("ground"):
			disable_physics()
		if collision.get_collider() is TowerBlock:
			var other_block:TowerBlock = collision.get_collider()
			if is_above_block(other_block): connect_to_block(other_block)

# Connect this block to the given tower block, snapping it in the correct position
# and disabling physics
func connect_to_block(other_block:TowerBlock):
	if other_block.upperBlockConnection != null or other_block.is_falling:
		#print("Connection is blocked!")
		pass
	else:
		#print("Successful connection!: (" + str(id) + " to " + str(other_block.id) + ")")
		other_block.upperBlockConnection = self
		lowerBlockConnection = other_block
		global_position = other_block.global_position + Vector2.UP*(blockDimensions.y-1)
		velocity = Vector2.ZERO
		disable_physics()

func is_above_block(other_block:TowerBlock):
	return position.y < other_block.position.y

func disconnect_upper():
	if is_instance_valid(upperBlockConnection):
		upperBlockConnection.lowerBlockConnection = null
		upperBlockConnection.enable_physics()
		upperBlockConnection = null

func disconnect_lower():
	if is_instance_valid(lowerBlockConnection):
		lowerBlockConnection.upperBlockConnection = null
		lowerBlockConnection = null
		enable_physics()

func disable_physics():
	is_falling = false
	velocity = Vector2.ZERO

func enable_physics():
	await get_tree().create_timer(0.08).timeout
	is_falling = true
	if upperBlockConnection:
		upperBlockConnection.disconnect_lower()

func on_hit():
	var pulse_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	sprite.scale = Vector2(0.9, 0.9)
	pulse_tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)
	
	var flash_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	flash_tween.tween_method(func(val):
		sprite.material.set_shader_parameter("fill_amount", val)
		, 1.0, 0.0, 0.15)
	hurt_sound.play()

func on_health_changed():
	var health_proportion = health_component.current_health/health_component.max_health
	health_bar.material.set_shader_parameter("fill_amount", health_proportion)
	update_debug_label()

func update_debug_label():
	debug_label.text = "ID: " + str(id) + "\nHealth: " + str(health_component.current_health)

func destroy():
	destroyed.emit()
	tower.remove_tower_block(self)
	#await get_tree().create_timer(1.0).timeout
	queue_free()
	disconnect_upper()
	disconnect_lower()
