extends Node3D

@onready var player:Player = $Player
@onready var gun:Gun = $"AK47-Projectile"
@onready var gun2:Gun = $"AK47-Projectile2"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	EventBus.pickup_item.emit(gun.get_item_instance(), player.player_inventory_id)
	EventBus.pickup_item.emit(gun2.get_item_instance(), player.player_inventory_id)
	pass # Replace with function body.
