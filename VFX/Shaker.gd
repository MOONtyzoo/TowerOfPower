# Used to keep track of a shaking offset that weakens over time
# Can apply an initial shake effect and run process on it every frame
extends RefCounted
class_name Shaker

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _new_x = 0.0
var _new_y = 0.0

var offset : Vector2 = Vector2.ZERO

func _ready():
	pass

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
	
	# Update new and previous sample points
	_last_shook_timer = _last_shook_timer + delta
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		var intensity = lerpf(_amplitude, 0.0, (_duration-_timer)/_duration)
		_previous_x = _new_x
		_previous_y = _new_y
		_new_x = intensity * randf_range(-1.0, 1.0)
		_new_y = intensity * randf_range(-1.0, 1.0)
	
	# Calculate camera offset based on progress between the sample points
	var lerp_progress = _last_shook_timer/_period_in_ms
	var x_component = lerpf(_previous_x, _new_x, lerp_progress)
	var y_component = lerpf(_previous_y, _new_y, lerp_progress)
	# Track how much we've moved the offset, as opposed to other effects.
	offset = Vector2(x_component, y_component)
		
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		offset = Vector2.ZERO

# Kick off a new screenshake effect.
func apply_shake(amplitude:float, frequency:float, duration:float):
	if frequency == 0: return
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_last_shook_timer = _period_in_ms
	_amplitude = amplitude
	_previous_x = 0
	_previous_y = 0
	_new_x = 0
	_new_y = 0
	# Reset previous offset, if any.
	offset = Vector2.ZERO

func get_offset() -> Vector2:
	return offset
