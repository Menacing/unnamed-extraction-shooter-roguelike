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
	EventBus.pickup_item.emit(gun._item_instance, player.player_inventory_id)
	pass # Replace with function body.
