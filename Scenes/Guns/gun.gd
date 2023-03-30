extends Node3D
class_name Gun

signal fired
signal reloaded

@export var _bullet_scene : PackedScene
var gun_stats:GunStats
var current_fire_mode:String

var Right_Hand:Node3D:
	get:
		return self.get_node("Right_Hand")
var Right_Fingers:Node3D:
	get:
		return self.get_node("Right_Fingers")
		
var Left_Hand:Node3D:
	get:
		return self.get_node("Left_Hand")
var Left_Fingers:Node3D:
	get:
		return self.get_node("Left_Fingers")

func _init(init_stats:GunStats):
	gun_stats = init_stats

func canFire() -> bool:
	return false
	
func fireGun():
	pass

func reloadGun():
	pass
	
func toggle_fire_mode() -> String:
	return ""
	
func make_transparent():
	pass

func make_opaque():
	pass


