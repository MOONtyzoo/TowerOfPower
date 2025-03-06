# Used for ghosts of objects that can be purchased on click
# Transparency fades in and out. Becomes more opaque and shows price tag on hover.
# On click it will take your money and trigger the on_purchase signal
extends Sprite2D
class_name PurchaseGhost

var cost:int = 250
var hover_state:bool = false

@onready var purchaseTab:PurchaseTab = $PurchaseTab
@onready var selection_indicator:Pointer = $SelectionIndicator

signal on_purchase

func _process(delta):
	if visible == true:
		update_hover_state()
		animate_shader(delta)

func update_hover_state():
	var new_hover_state:bool = get_rect().has_point(to_local(get_global_mouse_position()))
	if new_hover_state != hover_state: on_hover_state_change(new_hover_state)
	hover_state = new_hover_state
	
	if Input.is_action_just_pressed("leftClick") && get_rect().has_point(to_local(get_global_mouse_position())):
		attempt_purchase()

func attempt_purchase():
	# Logic here for checking if player can afford it and performing the transaction
	var money_manager:MoneyManager = Globals.money_manager
	var purchase_success = money_manager.attempt_purchase(cost)
	if purchase_success: on_purchase.emit()

func set_cost(new_cost:int):
	cost = new_cost
	purchaseTab.set_cost(cost)

var timer:float = 0.0
func animate_shader(delta):
	timer += delta
	var transparency = 0.65 + 0.05*cos(timer*2*PI / 2.0)
	
	if hover_state == false:
		material.set_shader_parameter("transparency", transparency)
	else:
		material.set_shader_parameter("transparency", 0.35)

func on_hover_state_change(new_hover_state:bool):
	#print("Hover state: " + str(new_hover_state))
	if new_hover_state == true:
		purchaseTab.focus()
		selection_indicator.focus()
	else:
		purchaseTab.unfocus()
		selection_indicator.unfocus()
