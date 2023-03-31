extends Node3D

@onready var player:Player = $Player
@onready var gun:Gun = $"AK47-Projectile"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var col_icomp = gun.get_node("ItemComponent")
	Events.player_inventory_try_pickup.emit(col_icomp)
	pass # Replace with function body.
