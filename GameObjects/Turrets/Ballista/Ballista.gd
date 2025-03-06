extends Node2D

@export var attack_range:float = 200.0
@export var attack_cooldown:float = 1.0
@export var projectile_speed:float = 250.0
@export var scn_projectile:PackedScene

@onready var pivot_point:Node2D = $PivotPoint
@onready var projectile_hook:Node2D = $PivotPoint/ProjectileHook

@onready var turret_placed_sound:AudioStreamPlayer2D = $TurretPlaced
@onready var shoot_sound:AudioStreamPlayer2D = $Shoot

var is_left:bool = true

var target:BaseEnemy

var time_since_last_search:float = 1.0

var attack_timer:float = attack_cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	turret_placed_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		aim_at_position(target.position)

func _physics_process(delta):
	if target == null:
		time_since_last_search -= delta
		if time_since_last_search < 0:
			if search_target():
				time_since_last_search = 1.0
	else:
		attack_timer -= delta
		if attack_timer < 0:
			attack_timer = attack_cooldown * randf_range(0.9, 1.1)
			shoot()

func search_target():
	var closest_enemy:BaseEnemy = get_closest_enemy()
	if closest_enemy == null:
		return false
	else:
		select_target(closest_enemy)
		return true

func select_target(new_target:BaseEnemy):
	if target != new_target:
		if target != null: target.died.disconnect(on_target_destroyed)
		new_target.died.connect(on_target_destroyed)
	target = new_target

func on_target_destroyed():
	target = null
	#search_target()

func get_closest_enemy():
	var enemies:Node2D = Globals.enemy_manager.enemies
	var closest_distance:float = 10000
	var closest_enemy:BaseEnemy = null
	
	for node in enemies.get_children():
		if !(node is BaseEnemy): continue
		var enemy:BaseEnemy = node
		if !is_enemy_on_same_side(enemy): continue
		if !is_enemy_in_range(enemy): continue
		if enemy.is_dead: continue
		var distance_to_enemy:float = pivot_point.global_position.distance_to(enemy.global_position)
		if distance_to_enemy < closest_distance:
			closest_enemy = enemy
			closest_distance = distance_to_enemy
	
	return closest_enemy

func is_enemy_on_same_side(enemy:BaseEnemy):
	return sign(position.x) == sign(enemy.position.x)

func is_enemy_in_range(enemy:BaseEnemy):
	return pivot_point.global_position.distance_to(enemy.position) < attack_range

func aim_at_position(aim_position:Vector2):
	pivot_point.look_at(aim_position)
	pivot_point.rotation = fmod(pivot_point.rotation + PI, 2*PI)
	if pivot_point.rotation > PI: pivot_point.rotation = -(2*PI - pivot_point.rotation)
	pivot_point.rotation = clamp(pivot_point.rotation, -PI/2.0, PI/2.0)

func shoot():
	var projectile:BaseProjectile = scn_projectile.instantiate()
	projectile.initialize(projectile_speed, -Vector2.from_angle(pivot_point.global_rotation), target)
	projectile.global_position = projectile_hook.global_position
	get_tree().current_scene.add_child(projectile)
	shoot_sound.play()
	
	var pulse_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	pivot_point.scale = Vector2(1.3, 1.3)
	pulse_tween.tween_property(pivot_point, "scale", Vector2.ONE, 0.55)
	search_target()
