extends CharacterBody2D
class_name BaseEnemy

@export var type:String = "BaseEnemy"
@export var power_level:float = 0 # Used to determine what enemies to spawn each wave
@export var is_flying:bool = false # Flying enemies spawn differently and ignore gravity
@export var coin_drop:int = 10

@export var attack_cooldown:float = 1.0 # Attacks per sescond
@export var attack_range:float = 45.0
@export var attack_range_spread:float = 15.0 # Used to create variation in a group of enemies when attacking
@export var movement_speed:float = 30.0
var random_seed:int

@onready var sprite:Sprite2D = $Sprite2D
@onready var health_component:HealthComponent = $HealthComponent
@onready var hurtbox_component:HurtboxComponent = $HurtboxComponent
@onready var state_machine:StateMachine = $StateMachine

@onready var hit_sound:AudioStreamPlayer2D = $Hit

var shaker:Shaker = Shaker.new()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var target : TowerBlock

signal died
var is_dead:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	random_seed = randi()
	randomize_attack_range()
	
	health_component.health_lost.connect(on_hit)
	health_component.health_depleted.connect(die)
	
	await get_tree().create_timer(0.5).timeout
	search_target()

func randomize_attack_range():
	const positions:int = 8.0
	var attack_range_variation:float = (rand_from_seed(random_seed)[0] % positions)/float(positions) * attack_range_spread*2 - attack_range_spread
	attack_range += attack_range_variation

func _process(delta):
	shaker._process(delta)
	sprite.offset = Vector2(shaker.get_offset().x, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func search_target()->bool:
	if !is_flying:
		if Globals.tower.tower_blocks.size() > 0:
			return select_target(Globals.tower.tower_blocks[0])
		else:
			return false
	else:
		if Globals.tower.tower_blocks.size() > 0:
			var closest_tower:TowerBlock = null
			var closest_distance:float = 10000
			for tower in Globals.tower.tower_blocks:
				var distance_to_tower = position.distance_to(tower.position)
				if distance_to_tower < closest_distance:
					closest_tower = tower
					closest_distance = distance_to_tower
			return select_target(closest_tower)
		else:
			return false

func select_target(new_target:TowerBlock)->bool:
	if target != new_target: new_target.destroyed.connect(on_target_destroyed)
	target = new_target
	return true

func on_target_destroyed():
	target = null
	state_machine.current_state = null
	state_machine.initial_state.transitioned.emit(null, state_machine.initial_state.name)

func is_left_of_target()->bool:
	return position.x < target.position.x

func is_in_range_of_target()->bool:
	return (!is_flying && horizontal_distance_to_target() < attack_range) || (is_flying && distance_to_target() < attack_range)

# The position that the enemy will aim at when attacking the target
func get_target_attack_hook():
	return Vector2((target.position.x - TowerBlock.blockDimensions.x/2.0 * (1 if is_left_of_target() else -1)), target.position.y)

func distance_to_target():
	return position.distance_to(get_target_attack_hook())

func horizontal_distance_to_target():
	return abs(position.x - get_target_attack_hook().x)

func vertical_distance_to_target():
	return abs(position.y - target.position.y)

func move_to_target(delta):
	apply_gravity(delta)
	if !is_flying:
		velocity.x = movement_speed * (1 if is_left_of_target() else -1)
	else:
		velocity = movement_speed * position.direction_to(target.position)
	sprite.flip_h = position.x > target.position.x
	move_and_slide()

func apply_gravity(delta):
	if !is_flying:
		if !is_on_floor():
			velocity.y += gravity * delta
	else:
		velocity = Vector2.ZERO

func stop_moving():
	velocity.x = 0

func on_hit():
	var pulse_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	sprite.scale = Vector2(0.9, 0.9)
	pulse_tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)
	
	var flash_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	flash_tween.tween_method(func(val):
		sprite.material.set_shader_parameter("fill_amount", val)
		, 1.0, 0.0, 0.15)
	if hit_sound:
		hit_sound.play()

func die():
	died.emit()
	is_dead = true
	Globals.money_manager.add_coins(coin_drop)
	state_machine.current_state.transitioned.emit(state_machine.current_state, "dead")

func play_shake_effect(amplitude:float, frequency:float, duration:float):
	shaker.apply_shake(amplitude, frequency, duration)
