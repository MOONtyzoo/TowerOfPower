extends Node2D
class_name Tower

var tower_blocks:Array[TowerBlock]
var top_block_falling:bool = false

var tallest_height:int = 0
var maximum_tower_height:int = 33

var hovered_turret_platform:TurretPlatform = null
var selected_turret_platform:TurretPlatform = null

var scn_tower_block:PackedScene = preload("res://GameObjects/TowerBlock/TowerBlock.tscn")

@onready var tower_block_purchase_ghost:PurchaseGhost = $TowerBlockPurchaseGhost
@onready var turret_build_menu:TurretBuildMenu = $TurretBuildMenu
@onready var selection_indicator:Pointer = $SelectionIndicator
@onready var score_line:Line2D = $ScoreLine

# Called when the node enters the scene tree for the first time.
func _ready():
	tower_block_purchase_ghost.on_purchase.connect(spawn_tower_block)
	turret_build_menu.on_turret_purchase.connect(on_turret_purchase)

func set_up_tower():
	spawn_tower_block()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tower_block_purchase_ghost.visible = !top_block_falling

func _physics_process(delta):
	if get_top_block():
		top_block_falling = get_top_block().is_falling
	else:
		false

func get_tower_height() -> int:
	return tower_blocks.size()

func get_top_block() -> TowerBlock:
	return tower_blocks[tower_blocks.size()-1] if tower_blocks.size() != 0 else null

var current_id:int = 1
func spawn_tower_block():
	var tower_block = scn_tower_block.instantiate()
	
	#tower_block.position = Vector2(0, 0)
	tower_block.tower = self
	tower_block.id = current_id
	current_id += 1
	add_child(tower_block)
	
	if tower_blocks.size() != 0:
		tower_block.connect_to_block(get_top_block())
	else:
		tower_block.position = Vector2(0, -31)
	
	tower_blocks.append(tower_block)
	tower_array_changed()

func remove_tower_block(tower_block:TowerBlock):
	tower_blocks.remove_at(tower_blocks.find(tower_block))
	tower_array_changed()
	
	if selection_indicator.get_parent().get_parent() == tower_block:
		selection_indicator.reparent(self)
		selection_indicator.unfocus()
		selection_indicator.position = Vector2.DOWN*1000
	
	if turret_build_menu.get_parent().get_parent() == tower_block:
		turret_build_menu.reparent(self)
		turret_build_menu.deactivate_menu()
		turret_build_menu.position = Vector2.DOWN*1000

func tower_array_changed():
	if get_tower_height() == 0:
		tower_block_purchase_ghost.reparent(self)
		tower_block_purchase_ghost.position = Vector2(0, -1000)
		print("Game over!")
	elif get_tower_height() >= maximum_tower_height:
		tower_block_purchase_ghost.reparent(self)
		tower_block_purchase_ghost.position = Vector2(0, 1000)
		print("Game win!")
	else:
		tower_block_purchase_ghost.reparent(get_top_block())
		tower_block_purchase_ghost.position = Vector2(0, -39)
	
	if get_tower_height() > tallest_height: set_tallest_height(get_tower_height())
	tower_block_purchase_ghost.set_cost(get_next_tower_cost())

func set_tallest_height(val:int):
	tallest_height = val
	if tallest_height == 6:
		Globals.camera.zoom_camera(false, 1.0)
		Globals.camera.can_zoom_out = true
	if tallest_height >= 6:
		update_score_line()
	Globals.camera.set_scroll_height_limit(get_top_block().position.y + -5.5*TowerBlock.blockDimensions.y)

func update_score_line():
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	var score_line_pos:Vector2 = ((TowerBlock.blockDimensions.y-1)*tallest_height + 13)*Vector2.UP
	tween.tween_property(score_line, "position", score_line_pos, 0.5)
	score_line.get_node("Label").text = "Tallest Floor: " + str(tallest_height)

func set_selected_turret_platform(platform:TurretPlatform):
	if selected_turret_platform == platform: return
	if platform != null && platform.is_built == true: return
	selected_turret_platform = platform
	
	if selected_turret_platform == hovered_turret_platform:
		selection_indicator.unfocus()
	
	if selected_turret_platform != null:
		turret_build_menu.reparent(selected_turret_platform)
		turret_build_menu.position = 15*Vector2.UP + 2*(Vector2.LEFT if selected_turret_platform.is_left_platform else Vector2.RIGHT)
		turret_build_menu.activate_menu(selected_turret_platform.is_left_platform)
	else:
		turret_build_menu.deactivate_menu()

func set_hovered_turret_platform(platform:TurretPlatform):
	if hovered_turret_platform == platform: return
	if selected_turret_platform != null && platform == selected_turret_platform: return
	if platform != null && platform.is_built == true: return
	hovered_turret_platform = platform
	
	if hovered_turret_platform != null:
		selection_indicator.focus()
		selection_indicator.reparent(hovered_turret_platform)
		selection_indicator.position = Vector2.ZERO
	else:
		selection_indicator.unfocus()

func on_turret_purchase(turret_name:String):
	var platform:TurretPlatform = selected_turret_platform
	#print(turret_name + "Purchased!")
	platform.deselect_platform(true)
	platform.build_turret(turret_name)

func get_next_tower_cost():
	return 200 + 10*get_tower_height()
