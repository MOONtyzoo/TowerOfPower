extends State

var enemy:BaseEnemy

@export var return_state:State
@export var attack_duration:float

@onready var hitbox_component:HitboxComponent = $HitboxComponent

var attack_loop_on:bool = false

# State machine provides all children with a reference to the controlled node
func initialize(base_node:Node2D):
	enemy = base_node

func enter():
	trigger_attack_loop()

func exit():
	if forward_tween:
		forward_tween.stop()
	if backward_tween:
		backward_tween.stop()
	enemy.position = start_position

func update(delta:float):
	pass

func physics_update(delta:float):
	enemy.apply_gravity(delta)

var forward_tween:Tween
var backward_tween:Tween
var start_position:Vector2
var attack_position:Vector2
func trigger_attack_loop():
	if attack_loop_on: return
	
	attack_loop_on = true
	while enemy.target && enemy.is_in_range_of_target():
		await get_tree().create_timer(enemy.attack_cooldown).timeout
		if enemy.target == null: exit_attack_loop(); break
		
		start_position = enemy.position
		attack_position = Vector2(enemy.get_target_attack_hook().x, start_position.y) if !enemy.is_flying else enemy.get_target_attack_hook()
		
		forward_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		forward_tween.tween_property(enemy, "position", attack_position, 0.33*attack_duration)
		hitbox_component.activate()
		await forward_tween.finished
		
		backward_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		backward_tween.tween_property(enemy, "position", start_position, 0.66*attack_duration)
		hitbox_component.deactivate()
		await backward_tween.finished
		if enemy.target == null: exit_attack_loop(); break
	
	attack_loop_on = false
	transitioned.emit(self, return_state.name)

func exit_attack_loop():
	attack_loop_on = false
	enemy.position = start_position
