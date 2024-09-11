extends Item3D
class_name Gun

signal fired
signal reloaded

var firer:Node3D

@warning_ignore("unused_private_class_variable")
@export var _bullet_scene : PackedScene
@export var ads_lean_factor:float = 1.0
@export var _gun_stats:GunStats

@export var muzzle:Node3D
@export var muzzle_flash_animation_player:AnimationPlayer
@export var fire_timer:Timer
@export var reload_timer:Timer
var reload_time:ModifiableStatFloat = ModifiableStatFloat.new(1.0)
var _new_bullets:int = 0
@export var reload_animation_player:AnimationPlayer


@export var gun_model_node:Node3D
@export var gun_material_nodes:Array[MeshInstance3D]
var gun_materials:Array[Material] = []

var scope:Scope
@export var scope_anchor:Node3D
@export var on_scope_show_nodes:Array[Node3D]
@export var on_scope_hide_nodes:Array[Node3D]

@export var on_default_magazine_show_nodes:Array[Node3D]
@export var on_default_magazine_hide_nodes:Array[Node3D]
@export var on_extended_magazine_show_nodes:Array[Node3D]
@export var on_extended_magazine_hide_nodes:Array[Node3D]

@export var on_stable_foregrip_show_nodes:Array[Node3D]
@export var on_stable_foregrip_hide_nodes:Array[Node3D]

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	super()
	if slot_data.current_ammo_subtype == null:
		slot_data.current_ammo_subtype = _gun_stats.ammo_type.sub_types[0]
		
	reload_timer.connect("timeout", reloaded_callback)

	fire_timer.wait_time = 60.0/_gun_stats.rpm
	current_fire_mode = _gun_stats.fire_modes[slot_data.current_fire_mode_index]
	reload_time.base_value = _gun_stats.reload_time_Sec
	reload_timer.wait_time = reload_time.get_modified_value()
	
	for gm_node in gun_material_nodes:
		var mat = gm_node.get_active_material(0)
		if mat:
			gun_materials.append(mat)
	
	if slot_data.internal_inventory:
		for eq:EquipmentSlot in slot_data.internal_inventory.equipment_slots:
			_on_item_equipment_changed(slot_data.internal_inventory, eq)

var current_fire_mode:String
var reloading: bool = false

func set_additional_slot_data(slot_data:SlotData) -> void:
	pass

func get_right_hand_node() -> Node3D:
	return self.get_node("Right_Hand")
	
func get_right_fingers_node() -> Node3D:
	return self.get_node("Right_Fingers")
		
func get_left_hand_node() -> Node3D:
	return self.get_node("Left_Hand")
	
func get_left_fingers_node() -> Node3D:
	return self.get_node("Left_Fingers")
	
func get_ads_anchor() -> Vector3:
	var base_position = self.get_node("ADS").position
	if scope:
		#if scope is equipped, get new x,y positions, keep z 
		var scope_offset = scope.get_ads_offset()
		base_position.x = scope_anchor.position.x + scope_offset.x
		base_position.y = scope_anchor.position.y + scope_offset.y
	return base_position
	
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
	if current_magazine_size > 0 and !reloading and fire_timer.time_left == 0:
		return true
	else:
		return false
	
func fireGun() -> void:
	if canFire():
		var bulletInst:IterativeRaycastBullet = _bullet_scene.instantiate()
		assign_bullet_stats(bulletInst, slot_data.current_ammo_subtype)
		bulletInst.firer = firer
		bulletInst.set_as_top_level(true)
		if !LevelManager.add_node_to_level(bulletInst):
			get_parent().add_child(bulletInst)
		
		bulletInst.global_transform.origin = muzzle.global_transform.origin
		bulletInst.global_basis = muzzle.global_basis
		Helpers.random_angle_deviation_moa(bulletInst, _gun_stats.moa, _gun_stats.moa)
		current_magazine_size -= 1
		muzzle_flash_animation_player.play("fire")
		#$ShotAudioStreamPlayer3D.play()
		fire_timer.start()
		fired.emit(generate_recoil())
	else:
		#click
		pass

func reloadGun(new_bullets:int) -> void:
	reload_timer.start(reload_time.get_modified_value())
	reloading = true
	reload_animation_player.play("reload")
	_new_bullets = new_bullets
	
func reloaded_callback():
	
	current_magazine_size = current_magazine_size + _new_bullets
	assert(current_magazine_size <= get_max_magazine_size())
	_new_bullets = 0
	reload_timer.stop()
	reloading = false
	reloaded.emit()
	
func toggle_fire_mode() -> String:
	var next_i = slot_data.current_fire_mode_index + 1
	if next_i > _gun_stats.fire_modes.size() - 1:
		slot_data.current_fire_mode_index = 0
	else:
		slot_data.current_fire_mode_index = next_i
	current_fire_mode = _gun_stats.fire_modes[slot_data.current_fire_mode_index]
	return current_fire_mode
	
var is_transparent: bool = false
func make_transparent():
	if !is_transparent:
		for gun_mat in gun_materials:
			gun_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
			gun_mat.distance_fade_max_distance = .75
			#Pixel dither looks better, but this is another way of doing it
			#gun_mat.blend_mode = gun_mat.BLEND_MODE_ADD
		is_transparent = true
		pass
	else:
		pass

func make_opaque():
	if is_transparent:
		for gun_mat in gun_materials:
			gun_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED		
		#gun_mat.blend_mode = gun_mat.BLEND_MODE_MIX
		is_transparent = false
	else:
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

var current_magazine_size:int:
	get:
		if slot_data is GunSlotData:
			return slot_data.current_number_bullets
		else:
			return 0
	set(value):
		if slot_data is GunSlotData:
			slot_data.current_number_bullets = value

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

func get_ammo_subtypes() -> Array[AmmoSubtype]:
	return _gun_stats.ammo_type.sub_types

func get_unselected_ammo_subtypes() -> Array[AmmoSubtype]:
	var all_subtypes:Array[AmmoSubtype] = _gun_stats.ammo_type.sub_types
	var less_selected:Array[AmmoSubtype] = []
	
	for ast:AmmoSubtype in all_subtypes:
		if ast.name != slot_data.current_ammo_subtype.name:
			less_selected.append(ast)
	
	return less_selected

func get_weapon_category() -> String:
	return _gun_stats.weapon_category_name
	
func assign_bullet_stats(bullet:IterativeRaycastBullet, subtype:AmmoSubtype):
	bullet.current_damage = subtype.initial_damage
	bullet.initial_speed = subtype.initial_speed
	bullet.current_speed = subtype.initial_speed
	bullet.pen_rating = subtype.armor_penetration_rating
	bullet.k = subtype.ballistic_coefficient_k
	
func copy_gun_model() -> Node3D:
	return gun_model_node.duplicate()
	
func move_attachment_to_anchor(attachment:Node3D, anchor:Node3D):
	if attachment:
		Helpers.force_parent(attachment, anchor)
		attachment.top_level = false
		attachment.transform = Transform3D.IDENTITY
		attachment.visible = true

var foregrips_equip_effect_component:EquipEffectComponent
var optics_equip_effect_component:EquipEffectComponent
var magazine_equip_effect_component:EquipEffectComponent

func _on_item_equipment_changed(inventory_data:InventoryData, equipment_slot:EquipmentSlot):
	match equipment_slot.slot_name:
		"OpticsSlot":
			if scope:
				scope.queue_free()
				scope = null
			hide_nodes(on_scope_show_nodes)
			show_nodes(on_scope_hide_nodes)
			if optics_equip_effect_component:
				self.remove_child(optics_equip_effect_component)
				optics_equip_effect_component.queue_free()
				optics_equip_effect_component = null
			
			if equipment_slot.slot_data:
				var item_3d = Item3D.instantiate_from_slot_data(equipment_slot.slot_data)
				scope = item_3d as Scope
				show_nodes(on_scope_show_nodes)
				hide_nodes(on_scope_hide_nodes)
				
				move_attachment_to_anchor(item_3d, scope_anchor)
				if equipment_slot.slot_data.item_data.equip_effect_component:
					optics_equip_effect_component = equipment_slot.slot_data.item_data.equip_effect_component.instantiate()
					self.add_child(optics_equip_effect_component)
			pass
		"MagsSlot":
			show_nodes(on_default_magazine_show_nodes)
			hide_nodes(on_default_magazine_hide_nodes)			
			if magazine_equip_effect_component:
				self.remove_child(magazine_equip_effect_component)
				magazine_equip_effect_component.queue_free()
				magazine_equip_effect_component = null
			if equipment_slot.slot_data:
				if equipment_slot.slot_data.item_data.item_type_id == "extended_magazine":
					show_nodes(on_extended_magazine_show_nodes)
					hide_nodes(on_extended_magazine_hide_nodes)
				if equipment_slot.slot_data.item_data.equip_effect_component:
					magazine_equip_effect_component = equipment_slot.slot_data.item_data.equip_effect_component.instantiate()
					self.add_child(magazine_equip_effect_component)
		"ForegripsSlot":
			show_nodes(on_stable_foregrip_hide_nodes)
			hide_nodes(on_stable_foregrip_show_nodes)
			if foregrips_equip_effect_component:
				self.remove_child(foregrips_equip_effect_component)
				foregrips_equip_effect_component.queue_free()
				foregrips_equip_effect_component = null
				
			if equipment_slot.slot_data:
				if equipment_slot.slot_data.item_data.item_type_id == "stable_foregrip":
					show_nodes(on_stable_foregrip_show_nodes)
					hide_nodes(on_stable_foregrip_hide_nodes)
				if equipment_slot.slot_data.item_data.equip_effect_component:
					foregrips_equip_effect_component = equipment_slot.slot_data.item_data.equip_effect_component.instantiate()
					self.add_child(foregrips_equip_effect_component)

	pass

func show_nodes(nodes_to_show:Array[Node3D]) -> void:
	for node in nodes_to_show:
		node.show()
		
func hide_nodes(nodes_to_hide:Array[Node3D]) -> void:
	for node in nodes_to_hide:
		node.hide()
	
