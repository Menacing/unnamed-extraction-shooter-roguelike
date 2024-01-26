extends Item3D
class_name Gun

signal fired
signal reloaded

@warning_ignore("unused_private_class_variable")
@export var _bullet_scene : PackedScene
@export var ads_lean_factor:float = 1.0
@export var _gun_stats:GunStats
@onready var current_magazine_size: int = _gun_stats.magazine_size

func _ready():
	super()

var current_fire_mode:String

func get_right_hand_node() -> Node3D:
	return self.get_node("Right_Hand")
	
func get_right_fingers_node() -> Node3D:
	return self.get_node("Right_Fingers")
		
func get_left_hand_node() -> Node3D:
	return self.get_node("Left_Hand")
	
func get_left_fingers_node() -> Node3D:
	return self.get_node("Left_Fingers")
	
func get_ads_anchor() -> Vector3:
	return self.get_node("ADS").position
	
func get_ads_head_anchor() -> Vector3:
	return self.get_node("ADS_Head").position
	
func get_hip_fire_anchor() -> Vector3:
	return self.get_node("HipFire").position
	
func get_grip_node() -> Node3D:
	return self.get_node("grip")
	
func get_handguard_node() -> Node3D:
	return self.get_node("handguard")

func canFire() -> bool:
	return false
	
func fireGun() -> void:
	pass

func reloadGun(_new_bullets:int) -> void:
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
	
func get_max_magazine_size() -> int:
	return _gun_stats.magazine_size

func copy_gun_model() -> Node3D:
	return Node3D.new()

func get_gun_stats() -> GunStats:
	return _gun_stats
