extends Node

var camera : CustomCamera
var tower : Tower
var money_manager : MoneyManager
var enemy_manager : EnemyManager
var number_manager : NumberManager

# preview texture, cost, scene
var turret_data:Dictionary = {
	"Ballista": [preload("res://GameObjects/Turrets/Ballista/BallistaFull.png"), 100, preload("res://GameObjects/Turrets/Ballista/Ballista.tscn")],
	#"Cannon": [preload("res://GameObjects/Turrets/Cannon/CannonFull.png"), 500, preload("res://GameObjects/Turrets/Cannon/Cannon.tscn")],
}

var enemy_data:Dictionary = {
	"GreenGoblin": [preload("res://GameObjects/Enemies/Goblins/GreenGoblin.tscn"), 6, false, 0],
	"BlueGoblin": [preload("res://GameObjects/Enemies/Goblins/BlueGoblin.tscn"), 35, false, 8],
	"RedBat": [preload("res://GameObjects/Enemies/Bats/RedBat.tscn"), 5, true, 6],
	"PurpleBat": [preload("res://GameObjects/Enemies/Bats/PurpleBat.tscn"), 50, true, 15],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
