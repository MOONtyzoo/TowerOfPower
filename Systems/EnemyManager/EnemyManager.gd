extends Node2D
class_name EnemyManager

@onready var left_spawn_hook:Node2D = $LeftSpawnHook
@onready var right_spawn_hook:Node2D = $RightSpawnHook
@onready var enemies:Node2D = $Enemies

@onready var scn_base_enemy:PackedScene = preload("res://GameObjects/Enemies/Goblins/GreenGoblin.tscn")

var summoning_enabled:bool = true
var summon_power:float = 0
var summon_power_generation:float = 0 # "Power" to determine the strength of enemies available to summon
var summon_timer:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if summoning_enabled:
		summon_timer -= delta
		if summon_timer < 0:
			summon_timer = randf_range(1.5, 5.0)
			summon_enemies()
	generate_power(delta)

func spawn_enemy(spawn_pos:Vector2):
	var enemy:BaseEnemy = scn_base_enemy.instantiate()
	enemies.add_child(enemy)
	enemy.position = spawn_pos

func summon_enemies():
	var tower_height = Globals.tower.get_tower_height()
	var ground_power = minf(6.0/tower_height, 1.0) * summon_power
	var flying_power = summon_power - ground_power
	
	var green_goblin_power:float = Globals.enemy_data["GreenGoblin"][1]
	var blue_goblin_power:float = Globals.enemy_data["BlueGoblin"][1]
	var red_bat_power:float = Globals.enemy_data["RedBat"][1]
	var purple_bat_power:float = Globals.enemy_data["PurpleBat"][1]
	
	var green_goblins_to_blue_goblins:float = blue_goblin_power/green_goblin_power
	var red_bats_to_purple_bats:float = purple_bat_power/red_bat_power
	var can_summon_blue_goblins:bool = Globals.tower.get_tower_height() >= 8
	var can_summon_purple_bats:bool = Globals.tower.get_tower_height() >= 15
	
	if !can_summon_blue_goblins:
		summon_enemy_group(Globals.enemy_data["GreenGoblin"], ground_power / green_goblin_power)
	else:
		var power_per_blue_goblin:float = green_goblins_to_blue_goblins*green_goblin_power + blue_goblin_power
		var num_blue_goblins:int = ground_power/power_per_blue_goblin
		summon_enemy_group(Globals.enemy_data["GreenGoblin"], green_goblins_to_blue_goblins*num_blue_goblins)
		summon_enemy_group(Globals.enemy_data["BlueGoblin"], num_blue_goblins)
	
	if !can_summon_purple_bats:
		summon_enemy_group(Globals.enemy_data["RedBat"], flying_power / red_bat_power)
	else:
		var power_per_purple_bat:float = red_bats_to_purple_bats*red_bat_power + purple_bat_power
		var num_purple_bats:int = flying_power/power_per_purple_bat
		summon_enemy_group(Globals.enemy_data["RedBat"], red_bats_to_purple_bats*num_purple_bats)
		summon_enemy_group(Globals.enemy_data["PurpleBat"], num_purple_bats)
	
	#var ground_enemies:Array
	#for enemy_data_key in Globals.enemy_data:
		#var enemy_data = Globals.enemy_data[enemy_data_key]
		#if enemy_data[2] == false && enemy_data[3] <= Globals.tower.get_tower_height():
			#ground_enemies.append(enemy_data)
	#var ground_power_sum = 0
	#for enemy_data in ground_enemies:
		#ground_power_sum += enemy_data[1]
	## use ground power sum to get the weight for enemy spawn chances, then do flying power sum. Enemy power is also spawn weight
	#for enemy_data in ground_enemies:
		#var proportion = ground_power*(enemy_data[1]/ground_power_sum)
		#var power_to_spend
	#
	#var flying_enemies:Array
	#for enemy_data_key in Globals.enemy_data:
		#var enemy_data = Globals.enemy_data[enemy_data_key]
		#if enemy_data[2] == true && enemy_data[3] <= Globals.tower.get_tower_height():
			#flying_enemies.append(enemy_data)
	#var flying_power_sum = 0
	#for enemy_data in flying_enemies:
		#flying_power_sum += enemy_data[1]
	

func summon_enemy_group(enemy_data, amount:int):
	for i in amount:
		summon_enemy(enemy_data)

func summon_enemy(enemy_data):
	var enemy_scene:PackedScene = enemy_data[0]
	var enemy_power:int = enemy_data[1]
	var enemy_is_flying:bool = enemy_data[2]
	
	if summon_power < enemy_power: return
	
	var spawn_hook_pos:Vector2 = left_spawn_hook.position if randi_range(0, 1) else right_spawn_hook.position
	var spawn_pos:Vector2
	
	summon_power -= enemy_power
	if enemy_is_flying == false:
		spawn_pos = spawn_hook_pos
	else:
		spawn_pos = Vector2(spawn_hook_pos.x, -randf_range(6.0*TowerBlock.blockDimensions.y, Globals.tower.get_tower_height()*TowerBlock.blockDimensions.y))
	spawn_pos += randf_range(-40, 40)*Vector2.RIGHT
	
	var enemy:BaseEnemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.position = spawn_pos

func generate_power(delta):
	# Assume ballista is 2dps per second, then that is 4dps per floor
	var max_tower_height:int = Globals.tower.maximum_tower_height-1
	var tower_height:int = Globals.tower.get_tower_height()
	summon_power_generation = pow(float(tower_height)/max_tower_height, 1.0)*max_tower_height*2.2 # Perhaps add a wave variation
	summon_power += summon_power_generation*delta
