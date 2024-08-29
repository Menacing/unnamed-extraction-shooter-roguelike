extends SteppingCharacterBody3D
class_name Player

@onready var state_chart :StateChart = %StateChart
@export var gun_scene1: PackedScene
@export var gun_scene2: PackedScene
var _equipped_gun:Gun
var equipped_gun:Gun:
	get:
		return _equipped_gun
	set(value):
		if _equipped_gun:
			_equipped_gun._on_unequipped(self)
		_equipped_gun = value
		if _equipped_gun:
			_equipped_gun._on_equipped(self)
		
var shoulder_gun:Gun
var gun_slot_1:Gun 
var gun_slot_2:Gun
@onready var waist = %Waist
@onready var chest = %Chest
@onready var cam = %Camera3D as Camera3D
@onready var head = %Head as Node3D
@onready var head_anchor = %HeadAnchor as Node3D

func set_head_anchor_position(pos:Vector3):
	head_anchor.position = pos

@onready var standing_head_anchor = %StandingHeadAnchor as Node3D
@onready var crouching_head_anchor = %CrouchingHeadAnchor as Node3D
@onready var prone_head_anchor = %ProneHeadAnchor as Node3D
@onready var use_shape:ShapeCast3D = %UseShape

var pov_rotation_node:Node3D

@onready var shoulder_anchor:Node3D = %HitBox/ChestBoneAttachment/shoulder_anchor
@onready var drop_location:Node3D = %DropLocation
@onready var armor_anchor:Node3D = %HitBox/ChestBoneAttachment/armor_anchor
@onready var backpack_anchor:Node3D = %HitBox/ChestBoneAttachment/backpack_anchor
@onready var center_mass:Node3D = %CenterMass
@onready var skeleton:Skeleton3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D
@onready var player_mesh_root:Node3D = %PlayerDefaultMeshAnimated
@onready var ik_right_hand:SkeletonIK3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/SkeletonIK3D_Hand_Right
@onready var ik_right_hand_fingers:SkeletonIK3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/SkeletonIK3D_Hand_Right_Fingers
@onready var ik_left_hand:SkeletonIK3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/SkeletonIK3D_Hand_Left_Fingers
@onready var ik_left_hand_fingers:SkeletonIK3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/SkeletonIK3D_Hand_Left
@onready var ik_head:SkeletonIK3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/SkeletonIK3D_Head
@onready var animation_tree:AnimationTree = $AnimationTree2
var los_check_locations:Array[Node3D] = []

@export_category("Movement")
@export_category("Standing")
@export var STANDING_HEIGHT = 1.8
@onready var _standing_mesh_root_height:float = player_mesh_root.position.y
@export var TO_STANDING_TIME = 0.25
@export var STANDING_BOB_TRANSLATION_X = 0.005
@export var STANDING_BOB_TRANSLATION_Y = 0.01
@export var STANDING_BOB_ROTATION_X = .75
@export var STANDING_BOB_ROTATION_Y = 1.5
@export_category("Walking")
@export var WALKING_SPEED = 4.0
@export var WALKING_BOB_TRANSLATION_X = 0.001
@export var WALKING_BOB_TRANSLATION_Y = 0.02
@export var WALKING_BOB_ROTATION_X = 1.0
@export var WALKING_BOB_ROTATION_Y = 3.0
@export_category("Crouching")
@export var CROUCH_SPEED = 1.5
@export var CROUCHING_HEIGHT = 1.3
@onready var _crouching_mesh_root_height = _standing_mesh_root_height + ((STANDING_HEIGHT - CROUCHING_HEIGHT)/2)
@export var TO_CROUCHING_TIME = 0.25
@export var CROUCHING_BOB_TRANSLATION_X = 0.0025
@export var CROUCHING_BOB_TRANSLATION_Y = 0.005
@export var CROUCHING_BOB_ROTATION_X = .5
@export var CROUCHING_BOB_ROTATION_Y = 1.0
@export var CROUCH_WALKING_BOB_TRANSLATION_X = 0.005
@export var CROUCH_WALKING_BOB_TRANSLATION_Y = 0.01
@export var CROUCH_WALKING_BOB_ROTATION_X = 1
@export var CROUCH_WALKING_BOB_ROTATION_Y = 2.5
@export_category("Prone")
@export var PRONE_SPEED = 2.0
@export var PRONE_HEIGHT = 0.5
@onready var _prone_mesh_root_height = _standing_mesh_root_height + ((STANDING_HEIGHT - PRONE_HEIGHT)/2)
@export var TO_PRONE_TIME = 0.25
@export var PRONE_BOB_TRANSLATION_X = 0.0
@export var PRONE_BOB_TRANSLATION_Y = 0.0
@export var PRONE_BOB_ROTATION_X = 0.0
@export var PRONE_BOB_ROTATION_Y = 0.0
@export var CRAWLING_BOB_TRANSLATION_X = 0.05
@export var CRAWLING_BOB_TRANSLATION_Y = 0.1
@export var CRAWLING_BOB_ROTATION_X = 5.0
@export var CRAWLING_BOB_ROTATION_Y = 10.0
@export_category("Running")
@export var RUN_SPEED = 8.0
@export var RUNNING_BOB_TRANSLATION_X = 0.1
@export var RUNNING_BOB_TRANSLATION_Y = 0.2
@export var RUNNING_BOB_ROTATION_X = 7.0
@export var RUNNING_BOB_ROTATION_Y = 12.0
@export_category("Jumping")
@export var JUMP_VELOCITY = 4.5
@export var JUMPING_BOB_TRANSLATION_X = 0.2
@export var JUMPING_BOB_TRANSLATION_Y = 0.4
@export var JUMPING_BOB_ROTATION_X = 7.0
@export var JUMPING_BOB_ROTATION_Y = 20.0
@export var accel = 1.0
var current_speed:ModifiableStatFloat = ModifiableStatFloat.new(0.0)
var current_bob_amount_x : ModifiableStatFloat = ModifiableStatFloat.new(0.01)
var current_bob_amount_y : ModifiableStatFloat = ModifiableStatFloat.new(0.01)
var current_bob_freq : ModifiableStatFloat = ModifiableStatFloat.new(0.0025)
var current_bob_amount_max_degrees_x : ModifiableStatFloat = ModifiableStatFloat.new(15.0)
var current_bob_amount_max_degrees_y : ModifiableStatFloat = ModifiableStatFloat.new(15.0)
var LEAN_AMOUNT = PI/6
@export_category("")

var current_fire_mode: String:
	get:
		if equipped_gun:
			return equipped_gun.current_fire_mode
		else: 
			return ""
			
var fully_ads: bool:
	get:
		if ads_fac == 1.0:
			return true
		else:
			return false
@onready var home_basis: Basis = waist.transform.basis
@warning_ignore("unsafe_method_access")
@onready var right_lean_basis: Basis = waist.transform.basis.rotated(Vector3.FORWARD, LEAN_AMOUNT)
@warning_ignore("unsafe_method_access")
@onready var left_lean_basis: Basis = waist.transform.basis.rotated(Vector3.FORWARD, -LEAN_AMOUNT)

var mouse_mov
var sway_threshold = 5
var sway_lerp = 5

@export var sway_left:Vector3
@export var sway_right:Vector3
@export var sway_normal:Vector3


var toggle_sprint_f: bool = false
var toggle_crouch_f: bool = false
var toggle_prone_f: bool = false
var toggle_inv_f: bool = false
var legs_destroyed: bool = false
var player_inventory_id:
	get: 
		return $PlayerInventories.player_inventory_id
	set(value):
		$PlayerInventories.player_inventory_id = value

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player_mat: BaseMaterial3D = %PlayerDefaultMeshAnimated/Armature/Skeleton3D/Head.get_active_material(0)

@onready var ammo_component:AmmoComponent = $AmmoComponent
@onready var ammo_subtype_selector:AmmoSubtypeSelector = $PlayerHUD/weapon_info_hud/VBoxContainer/AmmoSubtypeSelector

@onready var footstep_component:FootstepComponent = $FootstepComponent

@onready var main_health_component:HealthComponent = %MainHealthComponent
@onready var arms_health_component:HealthComponent = %ArmsHealthComponent
@onready var legs_health_component:HealthComponent = %LegsHealthComponent

signal armor_equipped(armor:BodyArmor)
signal armor_unequipped(armor:BodyArmor)

func _ready():
	if gun_scene1:
		equipped_gun = gun_scene1.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		#pick_up_gun(equipped_gun)item_inst
	if gun_scene2:
		shoulder_gun = gun_scene2.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		#pick_up_gun(shoulder_gun)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.fire_mode_changed.emit("")
	EventBus.magazine_ammo_count_changed.emit(0)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.item_removed_from_slot.connect(_on_item_removed_from_slot)
	EventBus.drop_item.connect(_on_drop_item)
	if toggle_inv_f:
		EventBus.open_inventory.emit(player_inventory_id)
	else:
		EventBus.close_all_inventories.emit()
	EventBus.ammo_type_changed.connect(_on_ammo_type_changed)
	EventBus.game_saving.connect(_on_game_saving)
	EventBus.before_game_loading.connect(_on_game_before_loading)
	
	los_check_locations.append(%HitBox/HeadBoneAttachment/eyes)
	los_check_locations.append(%HitBox/RightFootBoneAttachment)
	los_check_locations.append(%HitBox/LeftFootBoneAttachment)
	los_check_locations.append(%CenterMass)
	los_check_locations.append(%HitBox/RightLowerArmBoneAttachment/r_hand)
	los_check_locations.append(%HitBox/LeftLowerArmBoneAttachment/l_hand)
	
	ik_head.start()
	
	pov_rotation_node = chest


func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == player_inventory_id:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		
		send_item_pickup_message(item_instance)
		
		var item_3d:Item3D = ItemAccess.get_item_3d(item_instance.id_3d)
		Helpers.force_parent(item_3d,self)
		item_3d.picked_up(get_instance_id())
		if result.location.location == InventoryLocationResult.LocationType.SLOT:
			match result.location.slot_name:
				"GunSlot1":
					gun_slot_1 = item_3d as Gun
					move_gun_to_player_model(gun_slot_1)
				"GunSlot2":
					gun_slot_2 = item_3d as Gun
					move_gun_to_player_model(gun_slot_2) 
				"BackpackSlot":
					move_backpack_to_anchor(item_3d)
					var backpack:Backpack = item_3d as Backpack
					if backpack:
						if backpack.backpack_size == Backpack.Size.NONE:
							InventoryManager.set_inventory_size(player_inventory_id, Vector2i(7,2))
						elif backpack.backpack_size == Backpack.Size.SMALL:
							InventoryManager.set_inventory_size(player_inventory_id, Vector2i(7,4))
						elif backpack.backpack_size == Backpack.Size.MEDIUM:
							InventoryManager.set_inventory_size(player_inventory_id, Vector2i(7,6))
						elif backpack.backpack_size == Backpack.Size.LARGE:
							InventoryManager.set_inventory_size(player_inventory_id, Vector2i(7,8))
				"ArmorSlot":
					armor_equipped.emit(item_3d as BodyArmor)
					move_armor_to_anchor(item_3d)
		elif result.location.location == InventoryLocationResult.LocationType.GRID:
			item_3d.visible = false
		
		if item_instance.get_item_type() == GameplayEnums.ItemType.AMMO:
			var ammo_information:AmmoInformation = item_instance._item_info
			var remainder = ammo_component.add_ammo(ammo_information.ammo_type.name, ammo_information.ammo_subtype.name, item_instance.stacks)
			item_instance.stacks = remainder
			

func send_item_pickup_message(item_instance:ItemInstance):
	var message_text:String = "Picked up " + item_instance.get_display_name()
	
	if item_instance.get_has_stacks():
		message_text += " " + str(item_instance.stacks)
		
	EventBus.create_message.emit("pickup_"+str(item_instance.item_instance_id), message_text, 2.0)

func _on_item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String):
	if inventory_id == player_inventory_id:
		var item_3d:Item3D = ItemAccess.get_item_3d(item_inst.id_3d)
		if item_3d is Gun:
			if item_3d == equipped_gun:
				stop_arms_ik()
				equipped_gun = null	
			if item_3d == gun_slot_1:
				gun_slot_1 = null	
			if item_3d == gun_slot_2:
				gun_slot_2 = null	
			if item_3d == shoulder_gun:
				shoulder_gun = null
		if item_3d is BodyArmor:
			pass

func move_gun_to_player_model(gun:Gun):
	gun.show()	
	if !equipped_gun:
		move_gun_to_hands(gun)
	elif !shoulder_gun:
		move_gun_to_shoulder(gun)
	
func move_gun_to_hands(gun:Gun):
	equipped_gun = gun
	if gun:	
		gun.transform = Transform3D.IDENTITY
		gun.fired.connect(_on_gun_fired)
		gun.reloaded.connect(_on_gun_reloaded)
		current_fire_mode = gun.current_fire_mode
		Helpers.force_parent(gun, cam)
		EventBus.fire_mode_changed.emit(gun.current_fire_mode)
		EventBus.magazine_ammo_count_changed.emit(gun.current_magazine_size)
		gun.visible = true
		gun.top_level = true
		start_arms_ik(gun.get_right_hand_node(), gun.get_right_fingers_node(), gun.get_left_hand_node(), gun.get_left_fingers_node())
		
		var gun_stats = gun.get_gun_stats()
		ammo_component.set_active_ammo(gun_stats.ammo_type.name, gun_stats.ammo_type.sub_types[0].name)

func move_gun_to_shoulder(gun:Gun):
	shoulder_gun = gun
	if gun:
		Helpers.force_parent(gun,shoulder_anchor)
		gun.transform = Transform3D.IDENTITY
		gun.rotate_x(-PI/2)
		gun.visible = true
		gun.top_level = false
		pass

func move_armor_to_anchor(armor:Node3D):
	if armor:
		Helpers.force_parent(armor, armor_anchor)
		armor.transform = Transform3D.IDENTITY
		armor.visible = true
		pass
		
func move_backpack_to_anchor(backpack:Node3D):
	if backpack:
		Helpers.force_parent(backpack, backpack_anchor)
		backpack.transform = Transform3D.IDENTITY
		backpack.visible = true

func drop_equipped_gun():
	if equipped_gun:
		equipped_gun.fired.disconnect(_on_gun_fired)
		equipped_gun.reloaded.disconnect(_on_gun_reloaded)
		EventBus.fire_mode_changed.emit("")
		EventBus.magazine_ammo_count_changed.emit(0)
		
		equipped_gun = null
		stop_arms_ik()

func _on_drop_item(item_inst:ItemInstance, inventory_id:int):
	if inventory_id == player_inventory_id:
		var item_3d:Item3D = ItemAccess.get_item_3d(item_inst.id_3d)
		Helpers.force_parent(item_3d,get_parent())
		item_3d.dropped()
		item_3d.global_position = drop_location.global_position
		
		if item_3d is Gun:
			if item_3d == equipped_gun:
				stop_arms_ik()
				equipped_gun = null	
			if item_3d == gun_slot_1:
				gun_slot_1 = null	
			if item_3d == gun_slot_2:
				gun_slot_2 = null	
			if item_3d == shoulder_gun:
				shoulder_gun = null

#realtime inputs - movement stuff
func _physics_process(delta):
	#Emit event for player compass with player heading
	EventBus.compass_player_pulse.emit(self.global_position, self.global_rotation_degrees)
	
	#if not in inventory, handle real time inputs
	if !toggle_inv_f:
		
		#handle use hint
		#Enable when coliding and not disabled or disabled and not ads
		if use_shape.is_colliding() and (!GameSettings.disable_use_helper_when_ads or (GameSettings.disable_use_helper_when_ads and !fully_ads)):
				var col = use_shape.get_collider(0)
				if col:
					if col is Item3D:
						#Sometimes item instance is null when you pick object up
						var display_text = ''
						if col.get_item_instance():
							display_text = col.get_item_instance().get_display_short_name()
						EventBus.pickup_helper_visibility.emit(true, display_text)
					elif col.has_method("use"):
						EventBus.use_helper_visibility.emit(true)
				else:
					EventBus.use_helper_visibility.emit(false)
					EventBus.pickup_helper_visibility.emit(false, '')
		else:
			EventBus.use_helper_visibility.emit(false)
			EventBus.pickup_helper_visibility.emit(false, '')

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		#If inventories are closed, trigger the pause menu, else close open inventories
		if !toggle_inv_f:
			MenuManager.load_menu(MenuManager.MENU_LEVEL.PAUSE)
		else:
			close_inventory()
		

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	else:
		if event.is_action_pressed("toggleFireMode"):
			if equipped_gun.has_method("toggle_fire_mode"):
				var fire_mode = equipped_gun.toggle_fire_mode()
				EventBus.fire_mode_changed.emit(fire_mode)
				current_fire_mode = fire_mode
		elif event.is_action_pressed("use"):
			if use_shape.is_colliding():
				var col = use_shape.get_collider(0)
				if col is Item3D:
					EventBus.pickup_item.emit(col.get_item_instance(), player_inventory_id)
				elif col.has_method("use"):
					col.use(self)
		elif event.is_action_pressed("dropGun"):
			drop_equipped_gun()
		elif event.is_action_pressed("equipGunSlot1"):
			if !equipped_gun != gun_slot_1 :
				var old_gun = equipped_gun
				move_gun_to_hands(shoulder_gun)
				move_gun_to_shoulder(old_gun)
		elif event.is_action_pressed("equipGunSlot2"):
			if !equipped_gun != gun_slot_2 :
				var old_gun = equipped_gun
				move_gun_to_hands(shoulder_gun)
				move_gun_to_shoulder(old_gun)
		elif event.is_action_pressed("change_ammo_subtype"):
			if equipped_gun and !equipped_gun.reloading:
				var selector_request:AmmoSubtypeSelector.AmmoSubtypeSelectionRequest = AmmoSubtypeSelector.AmmoSubtypeSelectionRequest.new()
				selector_request.type = equipped_gun.get_ammo_type()
				selector_request.subtypes = []
				
				var current_request_item:AmmoSubtypeSelector.AmmoSubtypeSelectionRequestItem = AmmoSubtypeSelector.AmmoSubtypeSelectionRequestItem.new()
				current_request_item.subtype = equipped_gun.current_ammo_subtype
				current_request_item.current_amount = ammo_component.get_ammo_subtype_count(selector_request.type.name, current_request_item.subtype.name)
				selector_request.subtypes.append(current_request_item)
				
				for ast:AmmoSubtype in equipped_gun.get_unselected_ammo_subtypes():
					var request_item:AmmoSubtypeSelector.AmmoSubtypeSelectionRequestItem = AmmoSubtypeSelector.AmmoSubtypeSelectionRequestItem.new()
					request_item.subtype = ast
					request_item.current_amount = ammo_component.get_ammo_subtype_count(selector_request.type.name, request_item.subtype.name)
					selector_request.subtypes.append(request_item)
				
				ammo_subtype_selector.start_selection(selector_request) 
		elif event.is_action_pressed("quick_save"):
			SaveManager.quick_save()
		elif event.is_action_pressed("quick_load"):
			SaveManager.quick_load()

func toggle_inventory():
	toggle_inv_f = !toggle_inv_f
	
	if toggle_inv_f:
		open_inventory()
		if HideoutManager.in_hideout:
			HideoutManager.show_hideout_menu()
	else:
		close_inventory()
		if HideoutManager.in_hideout:
			HideoutManager.hide_hideout_menu()
		
func open_inventory():
	toggle_inv_f = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	EventBus.open_inventory.emit(player_inventory_id)
	state_chart.send_event("LegsBusy")
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
	
func close_inventory():
	toggle_inv_f = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.close_all_inventories.emit()
	state_chart.send_event("LegsDone")
	state_chart.send_event("ArmsDone")


func shoot():
	equipped_gun.fireGun()
	
func reload():
	var needed_ammo = equipped_gun.get_max_magazine_size() - equipped_gun.current_magazine_size
	var available_ammo = ammo_component.request_ammo(ammo_component._active_ammo_type, ammo_component._active_ammo_subtype, needed_ammo)
	equipped_gun.reloadGun(available_ammo)
	ik_left_hand.target_node = equipped_gun.get_mag_node().get_path()

func unload():
	var current_ammo = equipped_gun.current_magazine_size
	ammo_component.add_ammo(ammo_component._active_ammo_type, ammo_component._active_ammo_subtype, current_ammo)
	equipped_gun.current_magazine_size = 0

func _on_gun_fired(recoil:Vector2):
	EventBus.magazine_ammo_count_changed.emit(equipped_gun.current_magazine_size)
	var scaled_recoil = scale_recoil(recoil)
	v_rot_acc += scaled_recoil.x
	h_rot_acc += scaled_recoil.y


var recoil_factor:ModifiableStatFloat = ModifiableStatFloat.new(1.0)

func scale_recoil(recoil:Vector2) -> Vector2:
	return recoil * recoil_factor.get_modified_value()
	
func _on_gun_reloaded():
	EventBus.magazine_ammo_count_changed.emit(equipped_gun.current_magazine_size)
	ik_left_hand.target_node = equipped_gun.get_left_hand_node().get_path()
		
func _on_ammo_type_changed(new_type:String, new_subtype:String):
	#unload mag
	unload()
	#change ammo component ammo type
	ammo_component.set_active_ammo(new_type, new_subtype)
	#trigger reload animation
	reload()
	#change bullet scene
	equipped_gun._bullet_scene = AmmoLoader.get_ammo_subtype(new_type, new_subtype).bullet_scene
	ammo_subtype_selector.end_selection()
	
func _on_game_saving(save_file:SaveFile):
	if save_file:
		var player_information:TopLevelEntitySaveData = TopLevelEntitySaveData.new()
		player_information.global_transform = self.global_transform
		player_information.additional_data["v_rot_acc"] = v_rot_acc
		player_information.additional_data["h_rot_acc"] = h_rot_acc
		#player_information.path_to_parent = self.get_parent().get_path()
		player_information.scene_path = self.scene_file_path
		
		player_information.additional_data["player_inventory_id"] = player_inventory_id
		
		#save health
		main_health_component._on_game_saving(player_information)
		arms_health_component._on_game_saving(player_information)
		legs_health_component._on_game_saving(player_information)
		
		#save ammo
		player_information.additional_data["ammo_map"] = ammo_component._ammo_map
		player_information.additional_data["active_ammo_type"] = ammo_component._active_ammo_type
		player_information.additional_data["active_ammo_subtype"] = ammo_component._active_ammo_subtype
		
		
		save_file.top_level_entity_save_data.append(player_information)

func _on_game_before_loading():
	self.queue_free()
	
func _on_load_game(save_data:TopLevelEntitySaveData):
	if save_data:
		self.global_transform = save_data.global_transform
		v_rot_acc = save_data.additional_data["v_rot_acc"]
		h_rot_acc = save_data.additional_data["h_rot_acc"]
		
		player_inventory_id = save_data.additional_data["player_inventory_id"]
		
		#load health
		main_health_component._on_load_game(save_data)
		arms_health_component._on_load_game(save_data)
		legs_health_component._on_load_game(save_data)
		
		#load ammo
		ammo_component._ammo_map = save_data.additional_data["ammo_map"]
		ammo_component._active_ammo_type = save_data.additional_data["active_ammo_type"] 
		ammo_component._active_ammo_subtype = save_data.additional_data["active_ammo_subtype"]
	
var arm_destroyed_effect:GameplayEffect = load("res://game_objects/player/stat_modifiers/arm_destruction_effect.tres")
func _on_arms_destroyed(hc:HealthComponent):
	for effect in arm_destroyed_effect.effect_lists:
		effect.effect_target_node = self
	EventBus.create_effect.emit(self.get_instance_id(), arm_destroyed_effect)
			
func _on_main_destroyed(hc:HealthComponent):
	die()
			
func _on_arms_restored(hc:HealthComponent):
	EventBus.remove_effect.emit(self.get_instance_id(), arm_destroyed_effect)
	
func start_arms_ik(right_arm_loc:Node3D, right_fingers_loc:Node3D, left_arm_loc:Node3D, left_fingers_loc:Node3D):
	if right_arm_loc:
		ik_right_hand.target_node = right_arm_loc.get_path()
		ik_right_hand.start()
		
	if right_fingers_loc:
		ik_right_hand_fingers.target_node = right_fingers_loc.get_path()
		ik_right_hand_fingers.start()
		
	if left_arm_loc:
		ik_left_hand.target_node = left_arm_loc.get_path()
		ik_left_hand.start()
		
	if left_fingers_loc:
		ik_left_hand_fingers.target_node = left_fingers_loc.get_path()
		ik_left_hand_fingers.start()

func stop_arms_ik():
	ik_right_hand.stop()
	ik_right_hand_fingers.stop()
	ik_left_hand.stop()
	ik_left_hand_fingers.stop()
		
func calculate_fall_damage(vertical_velocity:float) -> float:
	var calc_damage = (200.0/6.0*abs(vertical_velocity)) - 300.0
	return max(0.0, calc_damage)

var alive = true

func die():
	alive = false
	animation_tree.active = false
	stop_arms_ik()
	ik_head.stop()
	skeleton.animate_physical_bones = true
	skeleton.physical_bones_start_simulation()
	collision_shape.disabled = true
	state_chart.process_mode = Node.PROCESS_MODE_DISABLED
	var player_hud:CanvasLayer = $PlayerHUD
	player_hud.visible = false
	var death_cam:Camera3D = %DeathCamera3D
	death_cam.current = true
	var death_animation_player:AnimationPlayer = %DeathAnimationPlayer
	death_animation_player.play("death_spiral")
	MenuManager.load_menu(MenuManager.MENU_LEVEL.DIED)
	
#region Movement Code

@onready var collision_shape:CollisionShape3D = $CollisionShape3D
@onready var collision_shape_shape:CapsuleShape3D = $CollisionShape3D.shape
var collision_shape_tween:Tween

func set_collision_shape_tween(collider_height:float,mesh_height:float, time:float, ease_type:Tween.EaseType, transition_type:Tween.TransitionType):
	if collision_shape_tween:
		collision_shape_tween.kill()
	collision_shape_tween = create_tween()
	collision_shape_tween.parallel().tween_property(collision_shape_shape, "height", collider_height, time)
	collision_shape_tween.parallel().tween_property(player_mesh_root, "position:y", mesh_height, time)
	collision_shape_tween.set_ease(ease_type)
	collision_shape_tween.set_trans(transition_type)

func should_sprint() -> bool:
	if GameSettings.toggle_sprint:
		if Input.is_action_just_pressed("sprint"):
			toggle_sprint_f = !toggle_sprint_f
		return toggle_sprint_f
	else:
		return Input.is_action_pressed("sprint")
		
func should_crouch() -> bool:
	if GameSettings.toggle_crouch:
		if Input.is_action_just_pressed("crouch"):
			toggle_crouch_f = !toggle_crouch_f
		return toggle_crouch_f
	else:
		return Input.is_action_pressed("crouch")
		
func should_prone() -> bool:
	if legs_destroyed:
		return true
	if Input.is_action_just_pressed("prone"):
		toggle_prone_f = !toggle_prone_f
	return toggle_prone_f


func move(move_global_velocity:Vector3, delta:float, going_forward:bool):
	if not is_on_floor():
		state_chart.send_event("Fell")
		return
	else:
		velocity.x = move_toward(velocity.x, move_global_velocity.x, accel)
		velocity.z = move_toward(velocity.z, move_global_velocity.z, accel)
	
	move_step_and_slide(delta)

#region Standing
@export var standing_recoil_factor:StatModifier
func _on_standing_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = STANDING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = STANDING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = STANDING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = STANDING_BOB_TRANSLATION_Y
	
	set_head_anchor_position(standing_head_anchor.position)
	
	recoil_factor.add_modifier(standing_recoil_factor)
	
	if collision_shape_shape.height != STANDING_HEIGHT:
		set_collision_shape_tween(STANDING_HEIGHT, _standing_mesh_root_height, TO_STANDING_TIME, Tween.EASE_IN, Tween.TRANS_QUART)
	
func _on_standing_state_exited():
	recoil_factor.remove_modifier(standing_recoil_factor)
	
func _on_standing_state_input(event):
	if event.is_action_pressed("jump") and !legs_destroyed and is_on_floor():
		state_chart.send_event("Jump")
		return
		
func _on_standing_state_physics_processing(delta):
	if should_crouch():
		state_chart.send_event("Crouch")
		return
	
	if should_prone():
		state_chart.send_event("Prone")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if !is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Walk")
		return
	else:
		move(direction, delta, input_direction.y < 0)

#endregion

#region Walking
@export var walking_recoil_factor:StatModifier
func _on_walking_state_entered():
	current_speed.base_value = WALKING_SPEED
	current_bob_amount_max_degrees_x.base_value = WALKING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = WALKING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = WALKING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = WALKING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(walking_recoil_factor)
	
	
func _on_walking_state_exited() -> void:
	current_bob_freq.remove_modifier(walking_recoil_factor)

	
func _on_walking_state_input(event):
	if event.is_action_pressed("jump") and !legs_destroyed and is_on_floor():
		state_chart.send_event("Jump")
		return
		
func _on_walking_state_physics_processing(delta):
	if should_crouch():
		state_chart.send_event("Crouch")
		return
	
	if should_prone():
		state_chart.send_event("Prone")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Stop")
		return
	elif should_sprint():
		state_chart.send_event("Sprint")
		return
	else:
		animation_tree["parameters/Walking/blend_position"] = input_direction
		
		move(direction * current_speed.get_modified_value(), delta, input_direction.y < 0)
#endregion

#region Sprinting
func _on_sprinting_state_input(event):
	if event.is_action_pressed("jump") and !legs_destroyed and is_on_floor():
		state_chart.send_event("Jump")
		return

@export var sprinting_recoil_factor:StatModifier
func _on_sprinting_state_entered():
	current_speed.base_value = RUN_SPEED
	current_bob_amount_max_degrees_x.base_value = RUNNING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = RUNNING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = RUNNING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = RUNNING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(sprinting_recoil_factor)
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
func _on_sprinting_state_exited():
	#Issue 350: Forcing toggle sprint off when you stop sprinting
	#otherwise it will stay on unless you tap sprint key WHILE moving
	toggle_sprint_f = false
	current_bob_freq.remove_modifier(sprinting_recoil_factor)
	state_chart.send_event("ArmsDone")
	

func _on_sprinting_state_physics_processing(delta):
	if should_crouch():
		state_chart.send_event("Crouch")
		return
	
	if should_prone():
		state_chart.send_event("Prone")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Stop")
		return
	elif !should_sprint():
		state_chart.send_event("Walk")
		return
	else:
		animation_tree["parameters/Sprinting/blend_position"] = input_direction
		move(direction * current_speed.get_modified_value(), delta, input_direction.y < 0)
#endregion
	
#region Crouching
@export var crouching_recoil_factor:StatModifier
@export var crouching_bob_freq:StatModifier


func _on_crouching_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = CROUCHING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = CROUCHING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = CROUCHING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = CROUCHING_BOB_TRANSLATION_Y
	recoil_factor.add_modifier(crouching_recoil_factor)
	current_bob_freq.add_modifier(crouching_bob_freq)
	
	set_head_anchor_position(crouching_head_anchor.position)
	
	if collision_shape_shape.height != CROUCHING_HEIGHT:
		set_collision_shape_tween(CROUCHING_HEIGHT, _crouching_mesh_root_height,TO_CROUCHING_TIME, Tween.EASE_IN, Tween.TRANS_QUART)
	
func _on_crouching_state_exited():
	recoil_factor.remove_modifier(crouching_recoil_factor)
	current_bob_freq.remove_modifier(crouching_bob_freq)

@export var crouch_walking_recoil_factor:StatModifier
func _on_crouch_walking_state_entered():
	current_speed.base_value = CROUCH_SPEED
	current_bob_amount_max_degrees_x.base_value = STANDING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = STANDING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = STANDING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = STANDING_BOB_TRANSLATION_Y
	recoil_factor.add_modifier(crouch_walking_recoil_factor)
	
func _on_crouch_walking_state_exited():
	recoil_factor.remove_modifier(crouch_walking_recoil_factor)

func _on_crouching_state_physics_processing(delta):
	if !should_crouch():
		state_chart.send_event("Stand")
		return
	
	if should_prone():
		state_chart.send_event("Prone")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if should_sprint():
		state_chart.send_event("Stand")
		return
	elif !is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("CrouchWalk")
		return
	else:
		move(direction, delta, input_direction.y < 0)
		
func _on_crouch_walking_state_physics_processing(delta):
	if !should_crouch():
		state_chart.send_event("Stand")
		return
	
	if should_prone():
		state_chart.send_event("Prone")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if should_sprint():
		state_chart.send_event("Stand")
		return
	elif is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Stop")
		return
	else:
		animation_tree["parameters/CrouchWalking/blend_position"] = input_direction
		
		move(direction * current_speed.get_modified_value(), delta, input_direction.y < 0)
#endregion

#region Prone
@export var prone_recoil_factor:StatModifier
func _on_prone_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = PRONE_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = PRONE_BOB_ROTATION_Y
	current_bob_amount_x.base_value = PRONE_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = PRONE_BOB_TRANSLATION_Y
	recoil_factor.add_modifier(prone_recoil_factor)
	
	set_head_anchor_position(prone_head_anchor.position)
	
	if collision_shape_shape.height != PRONE_HEIGHT:
		set_collision_shape_tween(PRONE_HEIGHT, _prone_mesh_root_height,TO_PRONE_TIME, Tween.EASE_IN, Tween.TRANS_QUART)
	
func _on_prone_state_exited():
	recoil_factor.remove_modifier_by_name("prone")

func _on_prone_state_physics_processing(delta):
	if should_crouch():
		state_chart.send_event("Crouch")
		return
	
	if !should_prone():
		state_chart.send_event("Stand")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if !is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Crawl")
		return
	else:
		move(direction, delta, input_direction.y < 0)
		

#endregion

#region Crawling
@export var crawling_recoil_factor:StatModifier
func _on_crawling_state_entered():
	current_speed.base_value = PRONE_SPEED
	current_bob_amount_max_degrees_x.base_value = CRAWLING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = CRAWLING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = CRAWLING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = CRAWLING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(crawling_recoil_factor)	
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
	
func _on_crawling_state_exited():
	current_bob_freq.remove_modifier(crawling_recoil_factor)
	state_chart.send_event("ArmsDone")
	
func _on_crawling_state_physics_processing(delta):
	if should_crouch():
		state_chart.send_event("Crouch")
		return
	
	if !should_prone():
		state_chart.send_event("Stand")
		return
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if is_equal_approx(input_direction.length(), 0.0):
		state_chart.send_event("Stop")
		return
	else:
		
		animation_tree["parameters/Crawling/blend_position"] = input_direction
		
		move(direction * current_speed.get_modified_value(), delta, input_direction.y < 0)
#endregion
	
#region Jumping
func _on_jumping_state_entered():
	velocity.y = JUMP_VELOCITY
	
func _on_jumping_state_exited():
	pass
	
func _on_jumping_state_physics_processing(delta):
		velocity.y -= gravity * delta
		move_step_and_slide(delta)
		return

var falling_velocity:float = 0.0
@export var falling_bob_freq:StatModifier
func _on_falling_state_entered() -> void:
	current_bob_amount_max_degrees_x.base_value = JUMPING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = JUMPING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = JUMPING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = JUMPING_BOB_TRANSLATION_Y
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	current_bob_freq.add_modifier(falling_bob_freq)		
	pass # Replace with function body.

func _on_falling_state_exited() -> void:
	current_bob_freq.remove_modifier(falling_bob_freq)
	state_chart.send_event("ArmsDone")
	
	var fall_damage = calculate_fall_damage(_real_velocity.y)
	if fall_damage > 0:
		legs_health_component.apply_damage(fall_damage)
	falling_velocity = 0.0
	pass # Replace with function body.

var _stuck_timer:float = 0.0
var _stuck_threshold = 5.0
func _on_falling_state_physics_processing(delta: float) -> void:
	
	if is_zero_approx(_real_velocity.y):
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0
		
	if _stuck_timer >= _stuck_threshold:
		state_chart.send_event("Stuck")
	elif not is_on_floor():
		var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
		var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
		var move_global_velocity = direction * current_speed.get_modified_value()
		velocity.x = move_toward(velocity.x, move_global_velocity.x, accel)
		velocity.z = move_toward(velocity.z, move_global_velocity.z, accel)
		velocity.y -= gravity * delta
		falling_velocity = velocity.y
		move_step_and_slide(delta)
	else:
		state_chart.send_event("Landed")
		return

func _on_stuck_state_entered():
	var unstuck_keybind:String = InputMap.action_get_events("unstuck")[0].as_text()
	var unstuck_message:String = "You appear to be stuck. Press %s to get unstuck" % unstuck_keybind
	EventBus.create_message.emit("unstuck_message", unstuck_message, -1)

func _on_stuck_state_exited():
	EventBus.remove_message.emit("unstuck_message")

@export_category("Navigation")
@export var nav_root:MultiAgentNavigationRoot
func _on_stuck_state_input(event):
	var input := event as InputEvent
	if input.is_action_pressed("unstuck"):
		#find nearby area on humanoid nav map
		var nmli = nav_root.get_navigation_mesh_list_item("humanoid")
		var global_pos := self.global_position
		var unstuck_point := NavigationServer3D.map_get_closest_point(nmli.map_rid, self.global_position)
		unstuck_point.y += 1.5
		#set position there
		self.global_position = unstuck_point
		#fall
		_stuck_timer = 0.0
		state_chart.send_event("Fell")

#endregion
#endregion

#region Arms Code
var _v_rot_acc:float = 0.0
var v_rot_acc:float:
	get:
		return _v_rot_acc
	set(value):
		_v_rot_acc = fmod(value, 2*PI)
var _h_rot_acc = 0.0
var h_rot_acc:float:
	get:
		return _h_rot_acc
	set(value):
		_h_rot_acc = fmod(value, 2*PI)
		_h_rot_acc = clampf(_h_rot_acc, -deg_to_rad(85), deg_to_rad(85))
func sway_transform_mouse(event: InputEventMouse):
	if (fully_ads):
		v_rot_acc += -event.relative.x * GameSettings.h_mouse_sens/2000.0 * GameSettings.ads_look_factor
		h_rot_acc += -event.relative.y * GameSettings.v_mouse_sens/2000.0 * GameSettings.ads_look_factor
	else:
		v_rot_acc += -event.relative.x * GameSettings.h_mouse_sens/2000.0
		h_rot_acc += -event.relative.y * GameSettings.v_mouse_sens/2000.0

func point_camera_at_target():
	head.transform.basis = Basis() # reset rotation
	head.rotate_object_local(Vector3(0, 1, 0), v_rot_acc) # first rotate in Y
	head.rotate_object_local(Vector3(1, 0, 0), h_rot_acc) # then rotate in X
	head.rotation.x = clampf(head.rotation.x, -deg_to_rad(85), deg_to_rad(85))


var _ads_fac = 0.0
var ads_fac:float:
	get:
		return _ads_fac
	set(value):
		if value < 0.0:
			_ads_fac = 0.0
		elif value > 1.0:
			_ads_fac = 1.0
		else:
			_ads_fac = value
			
func get_ads_acceleration() -> float:
	if equipped_gun:
		return 1.0 / equipped_gun.get_ADS_acceleration()
	else:
		return 0.0

func align_trailers_to_head(delta:float):
	#move head to anchor
	head.global_position = head_anchor.global_position
	
	#lerp horizontal body rotation to match camera
	var body_turn_speed = 4
	var body_source_y_quat = Quaternion(Basis(Vector3.UP,self.rotation.y))
	var body_target_y_quat = Quaternion(Basis(Vector3.UP,head.rotation.y))
	self.basis = body_source_y_quat.slerp(body_target_y_quat, body_turn_speed*delta)

	#match vertical rotation
	pov_rotation_node.rotation.x = head.rotation.x

func align_gun_trailer_to_head(delta:float):
	#calculate target positions

	var gun_ads_anchor = equipped_gun.get_ads_anchor()
	var gun_hf_anchor = equipped_gun.get_hip_fire_anchor()
	var gun_ads_head_anchor = equipped_gun.get_ads_head_anchor()
	var hf_head_global_position = head_anchor.global_position
	var hf_gun_global_position = head_anchor.global_position - (gun_hf_anchor * head.basis.inverse())
	var ads_head_global_position = head_anchor.global_position - (gun_ads_head_anchor * head.basis.inverse())
	var ads_gun_global_position = ads_head_global_position - (gun_ads_anchor * head.basis.inverse())

	var ads_fov = equipped_gun.get_ADS_FOV()
	
	#if fully ads, change transparency, else undo transparency
	if GameSettings.both_eyes_open_ads:
		if fully_ads:
				equipped_gun.make_transparent()
				#make_transparent()
		else:
				equipped_gun.make_opaque()
				#make_opaque()
	
	#set gun position between hipfire position and ads position by ads_factor
	equipped_gun.global_position = hf_gun_global_position.lerp(ads_gun_global_position, ads_fac)
	#set head anchor position between normal and ads position by ads_factor
	head.global_position = hf_head_global_position.lerp(ads_head_global_position, ads_fac)
	#set camera fov between default and ads fov by ads_factor
	#print("default fov: %s ads_fov %s ads_fac %s" % [GameSettings.default_fov, ads_fov, ads_fac])
	cam.fov = lerp(GameSettings.default_fov, ads_fov, ads_fac)

	var gun_turn_factor = 1.0 / equipped_gun.get_turn_speed()
	#get current rotation as quat
	var gun_source_y_quat = Quaternion(Basis(equipped_gun.basis))
	#get rotation of head to use as target as quat
	var gun_target_y_quat = Quaternion(Basis(head.basis))
	#slerp from source to target
	equipped_gun.basis = gun_source_y_quat.slerp(gun_target_y_quat, delta/gun_turn_factor)
	bob_equipped_gun(delta, equipped_gun, gun_turn_factor)


func bob_equipped_gun(delta:float, _equipped_gun:Node3D, gun_turn_factor:float) -> void:
	#Use something like this to calculate translation offset
	#Amplitude and Frequency should be influnce by movement state machine
	var raw_sin_y_result = sin(Time.get_ticks_msec() * current_bob_freq.get_modified_value())
	var raw_sin_x_result = sin(Time.get_ticks_msec() * current_bob_freq.get_modified_value() * 0.5)
	_equipped_gun.position.y = lerp(_equipped_gun.position.y, _equipped_gun.position.y + raw_sin_y_result * current_bob_amount_y.get_modified_value(), 10*delta)
	_equipped_gun.position.x = lerp(_equipped_gun.position.x, _equipped_gun.position.x + raw_sin_x_result * current_bob_amount_x.get_modified_value(), 10*delta)

	var bob_y_rot_deg = raw_sin_y_result * current_bob_amount_max_degrees_y.get_modified_value()
	var bob_x_rot_deg = raw_sin_x_result * current_bob_amount_max_degrees_x.get_modified_value()
	
	_equipped_gun.rotation_degrees.x = lerp(_equipped_gun.rotation_degrees.x, _equipped_gun.rotation_degrees.x + bob_y_rot_deg , 10 * delta)
	_equipped_gun.rotation_degrees.y = lerp(_equipped_gun.rotation_degrees.y, _equipped_gun.rotation_degrees.y + bob_x_rot_deg , 10 * delta)
	pass

var toggle_ads_f: bool = false
func shouldAds() -> bool:
	if !toggle_inv_f and equipped_gun:
		if GameSettings.toggle_ads:
			if Input.is_action_just_pressed("ads"):
				toggle_ads_f = !toggle_ads_f
			return toggle_ads_f
		else:
			return Input.is_action_pressed("ads")
	else:
		return false

func _on_ready_state_physics_processing(delta):
	if shouldAds():
		state_chart.send_event("ADS")
		return
		
	#Handle mouse look
	point_camera_at_target()
	align_trailers_to_head(delta)
	if equipped_gun:
		ads_fac -= delta / get_ads_acceleration()
		align_gun_trailer_to_head(delta)
		
		# Handle Shooting
		if current_fire_mode == "auto":
			if Input.is_action_pressed("shoot"):
				shoot()
		elif current_fire_mode == "semi":
			if Input.is_action_just_pressed("shoot"):
				shoot()
		
		if Input.is_action_just_pressed("reload") and !toggle_inv_f:
			reload()

func _on_ready_state_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		sway_transform_mouse(event)

func _on_ads_state_physics_processing(delta):
	if !shouldAds():
		state_chart.send_event("StopADS")
		return
	
	#Handle mouse look
	point_camera_at_target()
	align_trailers_to_head(delta)
	
	if equipped_gun:
		ads_fac += delta / get_ads_acceleration()
		align_gun_trailer_to_head(delta)
		# Handle Shooting
		if current_fire_mode == "auto":
			if Input.is_action_pressed("shoot"):
				shoot()
		elif current_fire_mode == "semi":
			if Input.is_action_just_pressed("shoot"):
				shoot()
		
		if Input.is_action_just_pressed("reload") and !toggle_inv_f:
			reload()
@export_category("ADS")
@export var ads_recoil_factor:StatModifier
@export var ads_bob_freq:StatModifier
@export var ads_speed:StatModifier
@export var ads_bob_max_x:StatModifier
@export var ads_bob_max_y:StatModifier
@export var ads_bob_x:StatModifier
@export var ads_bob_y:StatModifier
func _on_ads_state_entered():
	recoil_factor.add_modifier(ads_recoil_factor)
	current_bob_freq.add_modifier(ads_bob_freq)
	current_speed.add_modifier(ads_speed)
	
	current_bob_amount_max_degrees_x.add_modifier(ads_bob_max_x)
	current_bob_amount_max_degrees_y.add_modifier(ads_bob_max_y)
	current_bob_amount_x.add_modifier(ads_bob_x)
	current_bob_amount_y.add_modifier(ads_bob_y)
 
func _on_ads_state_exited():
	recoil_factor.remove_modifier_by_name("ADS")
	current_bob_freq.remove_modifier_by_name("ADS")
	current_speed.remove_modifier_by_name("ADS")
	current_bob_amount_max_degrees_x.remove_modifier_by_name("ADS")
	current_bob_amount_max_degrees_y.remove_modifier_by_name("ADS")
	current_bob_amount_x.remove_modifier_by_name("ADS")
	current_bob_amount_y.remove_modifier_by_name("ADS")

func _on_ads_state_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		sway_transform_mouse(event)
	
func _on_arms_busy_state_physics_processing(delta):
	#Handle mouse look
	point_camera_at_target()
	align_trailers_to_head(delta)
	if equipped_gun:
		ads_fac -= delta / get_ads_acceleration()
		align_gun_trailer_to_head(delta)
		
		if Input.is_action_just_pressed("reload") and !toggle_inv_f:
			reload()
	
	
func _on_arms_busy_state_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		sway_transform_mouse(event)
		
#endregion

#region Waist Code
var toggle_lean_l_f: bool = false
var toggle_lean_r_f: bool = false
func shouldLeanRight() -> bool:
	if !GameSettings.toggle_lean:
		return Input.is_action_pressed("leanRight")
	else:
		if Input.is_action_just_pressed("leanRight"):
			toggle_lean_r_f = !toggle_lean_r_f
			toggle_lean_l_f = false
		return toggle_lean_r_f

func  shouldLeanLeft() -> bool:
	if !GameSettings.toggle_lean:
		return Input.is_action_pressed("leanLeft")
	else:
		if Input.is_action_just_pressed("leanLeft"):
			toggle_lean_l_f = !toggle_lean_l_f
			toggle_lean_r_f = false
		return toggle_lean_l_f
		
func _on_center_state_physics_processing(delta):
	if shouldLeanLeft():
		state_chart.send_event("LeanLeft")
		return
	elif shouldLeanRight():
		state_chart.send_event("LeanRight")
		return
		
	waist.basis = Quaternion(waist.basis).slerp(Quaternion(home_basis),0.5)


func _on_left_state_physics_processing(delta):
	if !shouldLeanLeft():
		state_chart.send_event("StopLean")
		return
	waist.basis = Quaternion(waist.basis).slerp(Quaternion(left_lean_basis),0.5)

func _on_right_state_physics_processing(delta):
	if !shouldLeanRight():
		state_chart.send_event("StopLean")
		return
	waist.basis = Quaternion(waist.basis).slerp(Quaternion(right_lean_basis),0.5)
#endregion












func _on_damage_component_hit_occured(attack_result: AttackResult) -> void:
	pass # Replace with function body.
