extends Item3D
class_name Gun

signal fired
signal reloaded

@export var _bullet_scene : PackedScene
@export var ads_lean_factor:float = 1.0
@export var _gun_stats:GunStats
@onready var current_magazine_size: int = _gun_stats.magazine_size

func _ready():
	super()

var current_fire_mode:String

func get_right_hand_anchor() -> Node3D:
	return self.get_node("Right_Hand")
	
func get_right_fingers_anchor() -> Node3D:
	return self.get_node("Right_Fingers")
		
func get_left_hand_anchor() -> Node3D:
	return self.get_node("Left_Hand")
	
func get_left_fingers_anchor() -> Node3D:
	return self.get_node("Left_Fingers")
	
func get_ads_anchor() -> Node3D:
	return self.get_node("ADS")
	
func get_ads_head_anchor() -> Node3D:
	return self.get_node("ADS_Head")
	
func get_hip_fire_anchor() -> Node3D:
	return self.get_node("HipFire")
	
func get_grip_anchor() -> Node3D:
	return self.get_node("grip")
	
func get_handguard_anchor() -> Node3D:
	return self.get_node("handguard")

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

func copy_gun_model() -> Node3D:
	return Node3D.new()

func get_gun_stats() -> GunStats:
	return _gun_stats
