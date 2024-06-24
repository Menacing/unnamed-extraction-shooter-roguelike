extends Gun
class_name HICRifle
@warning_ignore("unsafe_method_access")
@onready var gun_mat: BaseMaterial3D = $gun/Node_15/gun/barrel/Cube.get_active_material(0)

var current_fire_mode_i = 0

var _new_bullets:int = 0
@onready var fire_timer:Timer = $FireTimer
@onready var reload_timer:Timer = $ReloadTimer
var reload_time:ModifiableStatFloat = ModifiableStatFloat.new(1.0)
@onready var muzzle_flash_animation_player:AnimationPlayer = %MuzzleFlashAnimationPlayer

@onready var scope_mount_model = $gun/Node_15/scope_mount
@onready var scope_anchor = $scope_anchor

var scope:Scope
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	reload_timer.connect("timeout", reloaded_callback)
	fire_timer.wait_time = 60.0/_gun_stats.rpm
	current_fire_mode = _gun_stats.fire_modes[current_fire_mode_i]
	reload_time.base_value = _gun_stats.reload_time_Sec
	reload_timer.wait_time = reload_time.get_modified_value()

func canFire() -> bool:
	if current_magazine_size > 0 and !reloading and fire_timer.time_left == 0:
		return true
	else:
		return false

func fireGun():
	if canFire():
		var muzzle = $gun/Muzzle
		
		var shoot_origin = muzzle.global_transform.origin
		
		var bulletInst:BulletProjRay = _bullet_scene.instantiate()
		bulletInst.moa = _gun_stats.moa
		bulletInst.set_as_top_level(true)		
		get_parent().add_child(bulletInst)
		bulletInst.global_transform.origin = shoot_origin
		bulletInst.firer = firer
		current_magazine_size -= 1
		muzzle_flash_animation_player.play("fire")
		$ShotAudioStreamPlayer3D.play()
		fire_timer.start()
		fired.emit(generate_recoil())
	else:
		#click
		pass

func reloadGun(new_bullets:int):
	reload_timer.start(reload_time.get_modified_value())
	reloading = true
	$AnimationPlayer.play("reload")
	_new_bullets = new_bullets
	
func reloaded_callback():
	
	current_magazine_size = current_magazine_size + _new_bullets
	assert(current_magazine_size <= get_max_magazine_size())
	_new_bullets = 0
	reload_timer.stop()
	reloading = false
	reloaded.emit()
	
func _on_equipped(player:Player):
	firer = player
	if reloading:
		reload_timer.paused = false
		print_debug("raw reload time left:" + str(reload_timer.time_left))
		for threshold in _gun_stats.reload_thresholds:
			if reload_timer.time_left < threshold:
				reload_timer.stop()
				reload_timer.start(threshold)
				break
		print_debug("reload time left after threshold:" + str(reload_timer.time_left))

	
func _on_unequipped(player:Player):
	firer = null
	if reloading:
		reload_timer.paused = true
		print_debug("reload time left:" + str(reload_timer.time_left))
		

func toggle_fire_mode() -> String:
	var next_i = current_fire_mode_i + 1
	if next_i > _gun_stats.fire_modes.size() - 1:
		current_fire_mode_i = 0
	else:
		current_fire_mode_i = next_i
	current_fire_mode = _gun_stats.fire_modes[current_fire_mode_i]
	return current_fire_mode

var is_transparent: bool = false
func make_transparent():
	if !is_transparent:
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
		gun_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED		
		#gun_mat.blend_mode = gun_mat.BLEND_MODE_MIX
		is_transparent = false
	else:
		pass

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == internal_inventory_id:
		super(result)
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_3d:Item3D = instance_from_id(item_instance.id_3d)
		if result.location.location == InventoryLocationResult.LocationType.SLOT:
			match result.location.slot_name:
				"OpticsSlot":
					scope = item_3d as Scope
					scope_mount_model.visible = true
					move_attachment_to_anchor(item_3d, scope_anchor)
					pass
				"MagsSlot":
					if item_instance.get_item_type_id() == "extended_magazine":
						$gun/Node_15/gun/mag/cube_003.visible = false
						$gun/Node_15/gun/mag/extended_magazine.visible = true
				"ForegripsSlot":
					if item_instance.get_item_type_id() == "stable_foregrip":
						$gun/Node_15/gun/handguard/default.visible = false
						$gun/Node_15/gun/handguard/stable.visible = true
			if item_3d is Attachment:
				var attachment:Attachment = item_3d as Attachment
				for effect in attachment.attachment_effect.effect_lists:
					effect.effect_target_node = self
				EventBus.create_effect.emit(firer.get_instance_id(), attachment.attachment_effect)
		elif result.location.location == InventoryLocationResult.LocationType.GRID:
			item_3d.visible = false
			
func move_attachment_to_anchor(attachment:Node3D, anchor:Node3D):
	if attachment:
		Helpers.force_parent(attachment, anchor)
		attachment.top_level = false
		attachment.transform = Transform3D.IDENTITY
		attachment.visible = true

func get_ads_anchor() -> Vector3:
	var base_position = super()
	if scope:
		base_position += scope.get_ads_offset()
	return base_position
	
func _on_item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String):
	if inventory_id == internal_inventory_id:
		var item_3d:Item3D = instance_from_id(item_inst.id_3d)
		match slot_name:
			"OpticsSlot":
				scope = null
				scope_mount_model.visible = false
				pass
			"MagsSlot":
				if item_inst.get_item_type_id() == "extended_magazine":
					$gun/Node_15/gun/mag/cube_003.visible = false
					$gun/Node_15/gun/mag/extended_magazine.visible = true
			"ForegripsSlot":
				if item_inst.get_item_type_id() == "stable_foregrip":
					$gun/Node_15/gun/handguard/default.visible = true
					$gun/Node_15/gun/handguard/stable.visible = false
		if item_3d is Attachment:
			var attachment:Attachment = item_3d as Attachment
			EventBus.remove_effect.emit(firer.get_instance_id(), attachment.attachment_effect)
