extends Sprite2D
class_name TurretPlatform

@export var is_left_platform:bool
var is_built:bool = false # is_built is true when the player builds the platform with a turret on it
var turret:Node2D = null
var hover_state:bool = false
var is_selected:bool = false

@onready var turret_hook:Node2D = $TurretHook

func _ready():
	material.set_shader_parameter("transparency", 0.85)

func _process(delta):
	if visible == true:
		update_hover_state()
		animate_shader(delta)

func update_hover_state():
	var new_hover_state:bool = get_rect().has_point(to_local(get_global_mouse_position()))
	if new_hover_state != hover_state: on_hover_state_change(new_hover_state)
	hover_state = new_hover_state
	
	if Input.is_action_just_pressed("leftClick"):
		if get_rect().has_point(to_local(get_global_mouse_position())):
			select_platform()

var timer:float = 0.0
func animate_shader(delta):
	timer += delta
	
	if is_built:
		material.set_shader_parameter("transparency", 0.0)
		return
	
	var transparency = 0.85 + 0.05*cos(timer*2*PI / 2.0)
	
	if hover_state == true || is_selected:
		material.set_shader_parameter("transparency", 0.33)
	else:
		material.set_shader_parameter("transparency", transparency)

func on_hover_state_change(new_hover_state:bool):
	#print("Hover state: " + str(new_hover_state))
	if new_hover_state == true:
		Globals.tower.set_hovered_turret_platform(self)
	else:
		Globals.tower.set_hovered_turret_platform(null)

func select_platform():
	if is_instance_valid(Globals.tower.selected_turret_platform):
		Globals.tower.selected_turret_platform.deselect_platform(false)
	Globals.tower.set_selected_turret_platform(self)
	is_selected = true
	animate_shader(0)

func deselect_platform(set_null:bool=false):
	if set_null: Globals.tower.set_selected_turret_platform(null)
	is_selected = false
	animate_shader(0)

func build_turret(turret_name:String):
	var turret_scene:PackedScene = Globals.turret_data[turret_name][2]
	turret = turret_scene.instantiate()
	is_built = true
	add_child(turret)
	turret.global_position = turret_hook.global_position
	turret.scale = Vector2(1, 1) if is_left_platform else Vector2(-1, 1)
	turret.is_left = is_left_platform
