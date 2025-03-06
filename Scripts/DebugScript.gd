# Temporary debug script used for activating certain game functions manually using number keys
extends Node2D

@onready var tower:Tower = $Tower
@onready var scn_base_enemy:PackedScene = preload("res://GameObjects/Enemies/BaseEnemy.tscn")

@export var debug_mode:bool = false

func _ready():
	Globals.camera = $CustomCamera
	Globals.tower = $Tower
	Globals.money_manager = $"UI-Layer/MoneyManager"
	Globals.enemy_manager = $EnemyManager
	Globals.number_manager = $NumberManager
	tower.set_up_tower()
	
	Globals.money_manager.add_coins(650)

func _process(delta):
	if debug_mode:
		debug_inputs()
	
	if Input.is_action_just_pressed("keyF"):
		toggle_fullscreen()

func debug_inputs():
	if Input.is_action_just_pressed("num1"):
		cash_injection()
	if Input.is_action_just_pressed("num2"):
		pass
	if Input.is_action_just_pressed("num3"):
		pass
	if Input.is_action_just_pressed("num4"):
		pass
	if Input.is_action_just_pressed("num5"):
		pass
	if Input.is_action_just_pressed("num6"):
		pass
	if Input.is_action_just_pressed("num7"):
		pass
	if Input.is_action_just_pressed("num8"):
		pass
	if Input.is_action_just_pressed("num9"):
		pass
	if Input.is_action_just_pressed("num0"):
		pass
	if Input.is_action_pressed("ctrl") && Input.is_action_just_pressed("leftClick"):
		spawn_enemy_at_mouse()

func toggle_fullscreen():
	var window_mode = DisplayServer.window_get_mode()
	if window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func cash_injection():
	var money_manager:MoneyManager = Globals.money_manager
	money_manager.add_coins(1000)

func spawn_enemy_at_mouse():
	Globals.enemy_manager.spawn_enemy(get_global_mouse_position())
