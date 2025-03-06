extends Node2D
class_name TurretBuildMenu

var is_active:bool = false

var selected_dict_index:int = 0
var is_on_left_platform:bool = true
var selected_turret_name:String = ""
var turret_cost:int = 0

@onready var left_arrow:Pointer = $LeftArrow
@onready var right_arrow:Pointer = $RightArrow
@onready var purchase_tab:PurchaseTab = $PurchaseTab
@onready var turret_preview:Sprite2D = $TurretPreview
@onready var animation_player:AnimationPlayer = $AnimationPlayer

signal on_turret_purchase

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		process_click_inputs()

func process_click_inputs():
	var left_arrow_rect:Rect2 = Rect2(left_arrow.position - Vector2(12, 12), Vector2(24, 24))
	if left_arrow_rect.has_point(to_local(get_global_mouse_position())) && is_active && left_arrow.visible:
		left_arrow.focus()
		if Input.is_action_just_pressed("leftClick"):
			select_index(selected_dict_index - 1)
	else:
		left_arrow.unfocus()
	
	var right_arrow_rect:Rect2 = Rect2(right_arrow.position - Vector2(12, 12), Vector2(24, 24))
	if right_arrow_rect.has_point(to_local(get_global_mouse_position())) && is_active && right_arrow.visible:
		right_arrow.focus()
		if Input.is_action_just_pressed("leftClick"):
			select_index(selected_dict_index + 1)
	else:
		right_arrow.unfocus()
	
	var purchase_rect:Rect2 = Rect2(position - Vector2(8, 0), Vector2(16, 28))
	if purchase_rect.has_point(to_local(get_global_mouse_position())) && is_active:
		purchase_tab.focus()
		if Input.is_action_just_pressed("leftClick"):
			attempt_purchase()
	else:
		purchase_tab.unfocus()
	
	var menu_rect:Rect2 = Rect2(position - Vector2(28, 28), Vector2(56, 56))
	if !menu_rect.has_point(to_local(get_global_mouse_position())) &&  Input.is_action_just_pressed("leftClick"):
		if Globals.tower.selected_turret_platform:
			Globals.tower.selected_turret_platform.deselect_platform(true)

func select_index(index:int):
	if index < 0 || index > Globals.turret_data.size(): return
	#print("Selecting index: " + str(index))
	selected_dict_index = index
	
	left_arrow.visible = index != 0
	right_arrow.visible = index != Globals.turret_data.size() - 1
	
	var key:String = Globals.turret_data.keys()[index]
	selected_turret_name = key
	var turret_data = Globals.turret_data[key]
	var turret_preview_tex:Texture2D = turret_data[0]
	turret_cost = turret_data[1]
	
	turret_preview.texture = turret_preview_tex
	turret_preview.flip_h = !is_on_left_platform
	turret_preview.offset.y = -turret_preview_tex.get_size().y/2.0 + 10
	
	purchase_tab.set_cost(turret_cost)

func attempt_purchase():
	var money_manager:MoneyManager = Globals.money_manager
	var purchase_success = money_manager.attempt_purchase(turret_cost)
	if purchase_success: on_turret_purchase.emit(selected_turret_name)

func activate_menu(is_left:bool):
	is_on_left_platform = is_left
	select_index(0)
	animation_player.play("expand", -1, 2.0)
	await animation_player.animation_finished
	#print("activate")
	is_active = true

func deactivate_menu():
	is_active = false
	#print("deactivate")
	animation_player.play("contract", -1, 1.0)
