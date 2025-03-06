extends Node2D
class_name MoneyManager

var coins:int = 0
@onready var cost_label:Label = $CoinCount/Label
@onready var purchase_sound:AudioStreamPlayer2D = $Purchase

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_label():
	cost_label.text = str(coins)

func add_coins(amount:int):
	coins += amount
	update_label()

func remove_coins(amount:int):
	coins = max(coins - amount, 0)
	update_label()

func can_purchase(cost:int):
	return coins >= cost

func attempt_purchase(cost:int) -> bool:
	if coins >= cost:
		remove_coins(cost)
		purchase_sound.play()
		return true
	else:
		return false
