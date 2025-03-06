extends Camera2D
class_name CustomCamera

@export var panning_speed:float = 300

var can_zoom_out:bool = false
var zoomed_in:bool = true

var camera_shaker : Shaker = Shaker.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera_input(delta)
	shake_camera(delta)

func camera_input(delta):
	if Input.is_action_just_pressed("zoomIn"):
		zoom_camera(true)
	if Input.is_action_just_pressed("zoomOut") && can_zoom_out:
		zoom_camera(false)
	
	var horizontal_pan_dir:float = Input.get_axis("pan_left", "pan_right")
	var vertical_pan_dir:float = Input.get_axis("pan_down", "pan_up")
	var camera_velocity = panning_speed*(Vector2.RIGHT*horizontal_pan_dir + Vector2.UP*vertical_pan_dir)*delta
	if !zoomed_in: camera_velocity *= 2
	position += camera_velocity
	position.x = clamp(position.x, limit_left + get_camera_size().x/2.0, limit_right - get_camera_size().x/2.0)
	position.y = clamp(position.y, limit_top + get_camera_size().y/2.0, limit_bottom - get_camera_size().y/2.0)

func zoom_camera(zoom:bool, zoom_speed:float=0.33):
	if zoomed_in == zoom: return
	# If the zoom changed
	zoomed_in = zoom
	
	var zoom_tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var target_zoom = Vector2(1.0, 1.0) if zoomed_in else Vector2(0.5, 0.5)
	zoom_tween.tween_property(self, "zoom", target_zoom, zoom_speed)

const hard_height_limit = -1350
func set_scroll_height_limit(scroll_height:float):
	limit_top = clamp(scroll_height, -1350 if can_zoom_out else -270, -270 if zoomed_in else -540)

# In pixels
func get_camera_size() -> Vector2:
	return get_viewport_rect().size / zoom

func frame_freeze(duration:float, time_scale:float=0.33):
	if duration == 0: return
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func parry_effect():
	$AudioStreamPlayers/Parry.playing = true
	frame_freeze(0.12, 0.067)

func tween_slowdown(tween:Tween, tween_duration:float, start:float, end:float, total_duration:float):
	if total_duration == 0: return
	tween.tween_method(set_time_scale, start, end, tween_duration)
	await tween.finished
	await get_tree().create_timer(total_duration - tween_duration, true, false, true).timeout
	Engine.time_scale = 1.0

func set_time_scale(val:float):
	Engine.time_scale = val

func apply_camera_shake(amplitude:float, frequency:float, duration:float):
	camera_shaker.apply_shake(amplitude, frequency, duration)

func shake_camera(delta):
	camera_shaker._process(delta)
	offset.x = camera_shaker.get_offset().x
