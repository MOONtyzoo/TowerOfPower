extends State

@export var death_knockback:float = 20.0
@export var death_time:float = 0.75

var enemy:BaseEnemy

# State machine provides all children with a reference to the controlled node
func initialize(base_node:Node2D):
	enemy = base_node

func enter():
	enemy.hurtbox_component.queue_free()
	
	var end_pos:Vector2 = enemy.position - death_knockback*Vector2.RIGHT*(-1 if enemy.sprite.flip_h else 1)
	var death_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	death_tween.tween_property(enemy, "position", end_pos, 0.8*death_time)
	death_tween.tween_method(func(val):
		enemy.sprite.material.set_shader_parameter("desaturation", val*0.66)
		enemy.sprite.material.set_shader_parameter("darkness", 1 + 0.2*val)
		, 0.0, 1.0, death_time)
	enemy.play_shake_effect(3, 75, death_time)
	await death_tween.finished
	await get_tree().create_timer(0.2*death_time)
	enemy.queue_free()

func exit():
	pass

func update(delta:float):
	pass

func physics_update(delta:float):
	pass
