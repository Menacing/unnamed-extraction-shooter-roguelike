extends Node3D
var _hit_count:int = 0
var hit_count:int = 0:
	get:
		return _hit_count
	set(value):
		_hit_count = value
		hit_count_label.text = str(value)
@onready var hit_count_label:Label = $CanvasLayer/Label
@onready var gun:Gun = $"AK47-Projectile"
@onready var player:Player = $Player
var fired_gun:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.players_spawned.emit()
	
	var armor_3d:Item3D = $light_armor_1
	armor_3d.spawn_item()
	
	EventBus.pickup_item.emit(armor_3d.get_item_instance(), player.player_inventory_id)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !fired_gun:
		gun.fireGun()
		fired_gun = true


func _on_csg_mesh_3d_object_hit():
	hit_count += 1


func _on_fire_timer_timeout():
	fired_gun = false
	hit_count = 0
