extends Item3D
class_name Gun

signal fired
signal reloaded

@export var _bullet_scene : PackedScene
@export var ads_lean_factor:float = 1.0
@export var _gun_stats:GunStats
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

func canFire() -> bool:
	return false
	
func fireGun() -> void:
	pass

func reloadGun() -> void:
	pass
	
func toggle_fire_mode() -> String:
	return ""
	
func make_transparent() -> void:
	pass

func make_opaque() -> void:
	pass

func get_ADS_acceleration() -> float:
	return _gun_stats.ads_accel
	
func get_turn_speed() -> float:
	return _gun_stats.turn_speed
	
func get_ADS_FOV() -> float:
	return _gun_stats.ads_fov
