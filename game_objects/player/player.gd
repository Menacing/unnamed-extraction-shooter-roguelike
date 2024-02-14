extends CharacterBody3D
class_name Player

@onready var state_chart :StateChart = %StateChart
@onready var world_collider:CollisionShape3D = $CollisionShape3d
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
@onready var waist = $Waist
@onready var chest = $Waist/Chest
@onready var cam = $Waist/Chest/head_anchor/Head/Camera3d as Camera3D
@onready var head = $Waist/Chest/head_anchor/Head as Node3D
@onready var head_anchor = $Waist/Chest/head_anchor as Node3D
@onready var use_ray = $Waist/Chest/head_anchor/Head/Camera3d/UsePointer
var pov_rotation_node:Node3D

@onready var shoulder_anchor:Node3D = $player_default_mesh_animated/shoulder_anchor
@onready var drop_location:Node3D = $drop_location
@onready var armor_anchor:Node3D = $HitBox/ChestBoneAttachment/armor_anchor
@onready var backpack_anchor:Node3D = $HitBox/ChestBoneAttachment/backpack_anchor
@onready var center_mass:Node3D = $center_mass
@onready var ik_right_hand:SkeletonIK3D = $player_default_mesh_animated/Armature/Skeleton3D/SkeletonIK3D_Hand_Right
@onready var ik_right_hand_fingers:SkeletonIK3D = $player_default_mesh_animated/Armature/Skeleton3D/SkeletonIK3D_Hand_Right_Fingers
@onready var ik_left_hand:SkeletonIK3D = $player_default_mesh_animated/Armature/Skeleton3D/SkeletonIK3D_Hand_Left_Fingers
@onready var ik_left_hand_fingers:SkeletonIK3D = $player_default_mesh_animated/Armature/Skeleton3D/SkeletonIK3D_Hand_Left
@onready var ik_head:SkeletonIK3D = $player_default_mesh_animated/Armature/Skeleton3D/SkeletonIK3D_Head
var los_check_locations:Array[Node3D] = []

@export_category("Movement")
@export_category("Standing")
@export var STANDING_HEIGHT = 2.0
@export var STANDING_BOB_TRANSLATION_X = 0.005
@export var STANDING_BOB_TRANSLATION_Y = 0.01
@export var STANDING_BOB_ROTATION_X = .75
@export var STANDING_BOB_ROTATION_Y = 1.5
@export_category("Walking")
@export var WALKING_SPEED = 5.0
@export var WALKING_BOB_TRANSLATION_X = 0.001
@export var WALKING_BOB_TRANSLATION_Y = 0.02
@export var WALKING_BOB_ROTATION_X = 1.0
@export var WALKING_BOB_ROTATION_Y = 3.0
@export_category("Crouching")
@export var CROUCH_SPEED = 1.5
@export var CROUCHING_HEIGHT = 1.0
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
@export var PRONE_BOB_TRANSLATION_X = 0.0
@export var PRONE_BOB_TRANSLATION_Y = 0.0
@export var PRONE_BOB_ROTATION_X = 0.0
@export var PRONE_BOB_ROTATION_Y = 0.0
@export var CRAWLING_BOB_TRANSLATION_X = 0.05
@export var CRAWLING_BOB_TRANSLATION_Y = 0.1
@export var CRAWLING_BOB_ROTATION_X = 5.0
@export var CRAWLING_BOB_ROTATION_Y = 10.0
@export_category("Running")
@export var RUN_SPEED = 10.0
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
var current_speed:ModifiableStat = ModifiableStat.new(0.0)
var current_bob_amount_x : ModifiableStat = ModifiableStat.new(0.01)
var current_bob_amount_y : ModifiableStat = ModifiableStat.new(0.01)
var current_bob_freq : ModifiableStat = ModifiableStat.new(0.0025)
var current_bob_amount_max_degrees_x : ModifiableStat = ModifiableStat.new(15.0)
var current_bob_amount_max_degrees_y : ModifiableStat = ModifiableStat.new(15.0)
var LEAN_AMOUNT = PI/6
@export_category("")

var current_fire_mode: String:
	get:
		if equipped_gun:
			return equipped_gun.current_fire_mode
		else: 
			return ""
@onready var ads_normal_pos: Vector3 = head_anchor.position
var grip_pos: Node3D
var handguard_pos: Node3D
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
@onready var player_inventory_id = $PlayerInventories.player_inventory_id

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player_mat: BaseMaterial3D = $player_default_mesh_animated/Armature/Skeleton3D/Head.get_active_material(0)

@onready var ammo_component:AmmoComponent = $AmmoComponent

func _ready():
	if gun_scene1:
		equipped_gun = gun_scene1.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		#pick_up_gun(equipped_gun)
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
	
	los_check_locations.append($HitBox/HeadBoneAttachment/eyes)
	los_check_locations.append($HitBox/RightFootBoneAttachment)
	los_check_locations.append($HitBox/LeftFootBoneAttachment)
	los_check_locations.append($center_mass)
	los_check_locations.append($HitBox/RightLowerArmBoneAttachment/r_hand)
	los_check_locations.append($HitBox/LeftLowerArmBoneAttachment/l_hand)
	
	ik_head.start()
	
	pov_rotation_node = chest

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == player_inventory_id:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_3d:Item3D = instance_from_id(item_instance.id_3d)
		Helpers.force_parent(item_3d,self)
		item_3d.picked_up()
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
					move_armor_to_anchor(item_3d)
		elif result.location.location == InventoryLocationResult.LocationType.GRID:
			item_3d.visible = false
		
		if item_instance.get_item_type() == GameplayEnums.ItemType.AMMO:
			var ammo_information:AmmoInformation = item_instance._item_info
			var remainder = ammo_component.add_ammo(ammo_information.ammo_type, ammo_information.ammo_subtype, item_instance.stacks)
			item_instance.stacks = remainder
			

func _on_item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String):
	if inventory_id == player_inventory_id:
		var item_3d:Item3D = instance_from_id(item_inst.id_3d)
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
		grip_pos = gun.get_grip_node()
		handguard_pos = gun.get_handguard_node()
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
		ammo_component.set_active_ammo(gun_stats.ammo_type, gun_stats.ammo_type.sub_types[0])

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
		var item_3d:Item3D = instance_from_id(item_inst.id_3d)
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
		if use_ray.is_colliding():
				var col = use_ray.get_collider()
				if col:
					if col is Item3D:
						EventBus.pickup_helper_visibility.emit(true)
					elif col.has_method("use"):
						EventBus.use_helper_visibility.emit(true)
				else:
					EventBus.use_helper_visibility.emit(false)
					EventBus.pickup_helper_visibility.emit(false)
		else:
			EventBus.use_helper_visibility.emit(false)
			EventBus.pickup_helper_visibility.emit(false)

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
			if use_ray.is_colliding():
				var col = use_ray.get_collider()
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
		
func toggle_inventory():
	toggle_inv_f = !toggle_inv_f
	
	if toggle_inv_f:
		open_inventory()
	else:
		close_inventory()
		
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


func _on_gun_fired(recoil:Vector2):
	EventBus.magazine_ammo_count_changed.emit(equipped_gun.current_magazine_size)
	var scaled_recoil = scale_recoil(recoil)
	v_rot_acc += scaled_recoil.x
	h_rot_acc += scaled_recoil.y


var recoil_factor:ModifiableStat = ModifiableStat.new(1.0)

func scale_recoil(recoil:Vector2) -> Vector2:
	return recoil * recoil_factor.get_modified_value()
	
func _on_gun_reloaded():
	EventBus.magazine_ammo_count_changed.emit(equipped_gun.current_magazine_size)	
		
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
	
var is_transparent: bool = false
func make_transparent():
	if !is_transparent:
		player_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
		#Pixel dither looks better, but this is another way of doing it
		#gun_mat.blend_mode = gun_mat.BLEND_MODE_ADD
		is_transparent = true
		pass
	else:
		pass

func make_opaque():
	if is_transparent:
		player_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED		
		#gun_mat.blend_mode = gun_mat.BLEND_MODE_MIX
		is_transparent = false
	else:
		pass
		
#region Movement Code
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

func move(move_velocity:Vector3, delta:float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = move_toward(velocity.x, move_velocity.x, accel)
		velocity.z = move_toward(velocity.z, move_velocity.z, accel)

	move_and_slide()

#region Standing
func _on_standing_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = STANDING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = STANDING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = STANDING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = STANDING_BOB_TRANSLATION_Y
	world_collider.get_shape().set_height(STANDING_HEIGHT)
	
	recoil_factor.add_modifier(StatModifier.new("standing", StatModifier.Operation.MUL, -0.1))
	
func _on_standing_state_exited():
	recoil_factor.remove_modifier_by_name("standing")
	
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
		move(direction, delta)

func _on_standing_transitions_physics_processing(delta):
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction:Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	move(direction, delta)
#endregion

#region Walking
func _on_walking_state_entered():
	current_speed.base_value = WALKING_SPEED
	current_bob_amount_max_degrees_x.base_value = WALKING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = WALKING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = WALKING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = WALKING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(StatModifier.new("walking", StatModifier.Operation.ADD, 0.0075))
	
func _on_walking_state_exited() -> void:
	current_bob_freq.remove_modifier_by_name("walking")

	
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
		move(direction * current_speed.get_modified_value(), delta)
#endregion

#region Sprinting
func _on_sprinting_state_input(event):
	if event.is_action_pressed("jump") and !legs_destroyed and is_on_floor():
		state_chart.send_event("Jump")
		return
	
func _on_sprinting_state_entered():
	current_speed.base_value = RUN_SPEED
	current_bob_amount_max_degrees_x.base_value = RUNNING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = RUNNING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = RUNNING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = RUNNING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(StatModifier.new("sprinting", StatModifier.Operation.ADD, 0.02))
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
func _on_sprinting_state_exited():
	current_bob_freq.remove_modifier_by_name("sprinting")
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
		move(direction * current_speed.get_modified_value(), delta)
#endregion
	
#region Crouching
func _on_crouching_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = CROUCHING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = CROUCHING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = CROUCHING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = CROUCHING_BOB_TRANSLATION_Y
	world_collider.get_shape().set_height(CROUCHING_HEIGHT)
	recoil_factor.add_modifier(StatModifier.new("crouching", StatModifier.Operation.MUL, -0.2))
	current_bob_freq.add_modifier(StatModifier.new("crouching", StatModifier.Operation.MUL, -0.5))
	
func _on_crouching_state_exited():
	recoil_factor.remove_modifier_by_name("crouching")
	current_bob_freq.remove_modifier_by_name("crouching")
	
func _on_crouch_walking_state_entered():
	current_speed.base_value = CROUCH_SPEED
	current_bob_amount_max_degrees_x.base_value = STANDING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = STANDING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = STANDING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = STANDING_BOB_TRANSLATION_Y
	recoil_factor.add_modifier(StatModifier.new("crouch_walking", StatModifier.Operation.MUL, -0.1))
	
func _on_crouch_walking_state_exited():
	recoil_factor.remove_modifier_by_name("crouch_walking")

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
		move(direction, delta)
		
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
		move(direction * current_speed.get_modified_value(), delta)
#endregion

#region Prone
func _on_prone_state_entered():
	current_speed.base_value = 0.0
	current_bob_amount_max_degrees_x.base_value = PRONE_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = PRONE_BOB_ROTATION_Y
	current_bob_amount_x.base_value = PRONE_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = PRONE_BOB_TRANSLATION_Y
	world_collider.get_shape().set_height(PRONE_HEIGHT)
	recoil_factor.add_modifier(StatModifier.new("prone", StatModifier.Operation.MUL, -0.4))
	
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
		move(direction, delta)
		
func _on_prone_transitions_entered():
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	

func _on_prone_transitions_exited():
	state_chart.send_event("ArmsDone")
#endregion

#region Crawling
func _on_crawling_state_entered():
	current_speed.base_value = PRONE_SPEED
	current_bob_amount_max_degrees_x.base_value = CRAWLING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = CRAWLING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = CRAWLING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = CRAWLING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(StatModifier.new("crawling", StatModifier.Operation.MUL, -0.5))	
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
	
func _on_crawling_state_exited():
	current_bob_freq.remove_modifier_by_name("crawling")
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
		move(direction * current_speed.get_modified_value(), delta)
#endregion
	
#region Jumping
func _on_jumping_state_entered():
	velocity.y = JUMP_VELOCITY
	current_bob_amount_max_degrees_x.base_value = JUMPING_BOB_ROTATION_X
	current_bob_amount_max_degrees_y.base_value = JUMPING_BOB_ROTATION_Y
	current_bob_amount_x.base_value = JUMPING_BOB_TRANSLATION_X
	current_bob_amount_y.base_value = JUMPING_BOB_TRANSLATION_Y
	current_bob_freq.add_modifier(StatModifier.new("jumping", StatModifier.Operation.MUL, -0.7))		
	state_chart.send_event("ArmsBusy")
	state_chart.send_event("StopLean")
	
	
func _on_jumping_state_exited():
	current_bob_freq.remove_modifier_by_name("jumping")
	state_chart.send_event("ArmsDone")
	
func _on_jumping_state_physics_processing(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
	else:
		state_chart.send_event("LegsDone")
		return
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
		v_rot_acc += -event.relative.x * GameSettings.h_mouse_sens/1000.0 * GameSettings.ads_look_factor
		h_rot_acc += -event.relative.y * GameSettings.v_mouse_sens/1000.0 * GameSettings.ads_look_factor
	else:
		v_rot_acc += -event.relative.x * GameSettings.h_mouse_sens/1000.0
		h_rot_acc += -event.relative.y * GameSettings.v_mouse_sens/1000.0

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
	var ads_rotated_offset = (cam.position - equipped_gun.get_ads_anchor()) * head.basis.inverse()
	var ads_g_pos = head.global_position + ads_rotated_offset
	var hf_rotated_offset = (cam.position - equipped_gun.get_hip_fire_anchor()) * head.basis.inverse()
	var hf_g_pos = head.global_position + hf_rotated_offset
	var ads_fov = equipped_gun.get_ADS_FOV()
		
	#if fully ads, change transparency, else undo transparency
	if GameSettings.both_eyes_open_ads:
		if fully_ads:
				equipped_gun.make_transparent()
				make_transparent()
		else:
				equipped_gun.make_opaque()
				make_opaque()
	
	#set gun position between hipfire position and ads position by ads_factor
	equipped_gun.global_position = hf_g_pos.lerp(ads_g_pos, ads_fac)
	#set head anchor position between normal and ads position by ads_factor
	head_anchor.transform.origin = ads_normal_pos.lerp(equipped_gun.get_ads_head_anchor(), ads_fac)
	#set camera fov between default and ads fov by ads_factor
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
		
		if Input.is_action_just_pressed("reload"):
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
		
		if Input.is_action_just_pressed("reload"):
			reload()

func _on_ads_state_entered():
	recoil_factor.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.2))
	current_bob_freq.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.2))
	current_speed.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.4))
	
	current_bob_amount_max_degrees_x.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.4))
	current_bob_amount_max_degrees_y.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.4))
	current_bob_amount_x.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.4))
	current_bob_amount_y.add_modifier(StatModifier.new("ADS", StatModifier.Operation.MUL, -0.4))
 
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
		
		if Input.is_action_just_pressed("reload"):
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







