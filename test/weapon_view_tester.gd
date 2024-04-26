extends Node3D

@onready var player:Player = $Player
@onready var gun:Gun = $S5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout():
	EventBus.pickup_item.emit(gun.get_item_instance(), player.player_inventory_id)
