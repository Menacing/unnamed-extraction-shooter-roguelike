extends Item3D
class_name Gun

signal fired
signal reloaded

var firer:Node3D

@warning_ignore("unused_private_class_variable")
@export var _bullet_scene : PackedScene
@export var ads_lean_factor:float = 1.0
@export var _gun_stats:GunStats

@export var current_ammo_subtype:AmmoSubtype

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	super()
	current_ammo_subtype = _gun_stats.ammo_type.sub_types[0]

var current_fire_mode:String
var reloading: bool = false

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

@export var mag_node:Node3D
func get_mag_node() -> Node3D:
	return mag_node

func _on_equipped(player:Player):
	pass
	
func _on_unequipped(player:Player):
	pass
	
func dropped() -> void:
	super()
	firer = null

func picked_up(actor_id:int = 0) -> void:
	super()
	var actor_object = instance_from_id(actor_id)
	if actor_object is Node3D:
		firer = actor_object

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

@onready var _ads_acceleration: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.ads_accel)
func get_ADS_acceleration() -> float:
	return _ads_acceleration.get_modified_value()

@onready var _turn_speed: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.turn_speed)
func get_turn_speed() -> float:
	return _turn_speed.get_modified_value()
	
@onready var _ads_fov: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.ads_fov)
func get_ADS_FOV() -> float:
	return _ads_fov.get_modified_value()
	
@onready var _magazine_size: ModifiableStatInt = ModifiableStatInt.new(_gun_stats.magazine_size)
func get_max_magazine_size() -> int:
	return _magazine_size.get_modified_value()

@onready var current_magazine_size: int = get_max_magazine_size()

@onready var _base_recoil_x: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.base_recoil.x)
func get_base_recoil_x() -> float:
	return _base_recoil_x.get_modified_value()
	
@onready var _base_recoil_y: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.base_recoil.y)
func get_base_recoil_y() -> float:
	return _base_recoil_y.get_modified_value()
	
@onready var _variable_recoil_x: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.recoil_variability.x)
func get_variable_recoil_x() -> float:
	return _variable_recoil_x.get_modified_value()
	
@onready var _variable_recoil_y: ModifiableStatFloat = ModifiableStatFloat.new(_gun_stats.recoil_variability.y)
func get_variable_recoil_y() -> float:
	return _variable_recoil_y.get_modified_value()

func generate_recoil() -> Vector2:
	var base_x = get_base_recoil_x()
	var base_y = get_base_recoil_y()
	var var_x = get_variable_recoil_x()
	var var_y = get_variable_recoil_y()
	
	
	return Vector2(get_base_recoil_x() + rng.randf_range(-get_variable_recoil_x(), get_variable_recoil_x()), \
		get_base_recoil_y() + rng.randf_range(-get_variable_recoil_y(), get_variable_recoil_y()))

func get_gun_stats() -> GunStats:
	return _gun_stats

func get_ammo_type() -> AmmoType:
	return _gun_stats.ammo_type

func get_unselected_ammo_subtypes() -> Array[AmmoSubtype]:
	var all_subtypes:Array[AmmoSubtype] = _gun_stats.ammo_type.sub_types
	var less_selected:Array[AmmoSubtype] = []
	
	for ast:AmmoSubtype in all_subtypes:
		if ast.name != current_ammo_subtype.name:
			less_selected.append(ast)
	
	return less_selected
