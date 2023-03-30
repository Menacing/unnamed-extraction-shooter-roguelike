extends CharacterBody3D
class_name Player

@export var gun_scene1: PackedScene
@export var gun_scene2: PackedScene
@export var max_health:float = 100.0
@onready var health:float = max_health
var equipped_gun:Gun
var shoulder_gun:Gun
var gun_slot_1:Gun 
var gun_slot_2:Gun
@onready var waist = $Waist
@onready var chest = $Waist/Chest
@onready var cam = $Waist/Chest/Head/Camera3d as Camera3D
@onready var head = $Waist/Chest/Head as Node3D
@onready var pmsm = $PlayerMotionStateMachine
@onready var use_ray = $Waist/Chest/Head/Camera3d/UsePointer
var pov_rotation_node:Node3D

@onready var shoulder_anchor:Node3D = $player_default_mesh/shoulder_anchor
@onready var drop_location:Node3D = $drop_location
@onready var armor_anchor:Node3D = $HitBox/ChestBoneAttachment/armor_anchor
@onready var backpack_anchor:Node3D = $HitBox/ChestBoneAttachment/backpack_anchor
@onready var center_mass:Node3D = $center_mass
@onready var ik_right_hand:SkeletonIK3D = $player_default_mesh/metarig/Skeleton3D/SkeletonIK3D_Hand_Right
@onready var ik_right_hand_fingers:SkeletonIK3D = $player_default_mesh/metarig/Skeleton3D/SkeletonIK3D_Hand_Right_Fingers
@onready var ik_left_hand:SkeletonIK3D = $player_default_mesh/metarig/Skeleton3D/SkeletonIK3D_Hand_Left
@onready var ik_left_hand_fingers:SkeletonIK3D = $player_default_mesh/metarig/Skeleton3D/SkeletonIK3D_Hand_Left_Fingers
@onready var ik_head:SkeletonIK3D = $player_default_mesh/metarig/Skeleton3D/SkeletonIK3D_Head
var los_check_locations:Array[Node3D] = []

var mouseSensibility = 1200
@export var mouse_sensitivity = 0.005
var mouse_relative_x = 0
var mouse_relative_y = 0
const NORMAL_SPEED = 5.0
const CROUCH_SPEED = 2.5
const PRONE_SPEED = 1
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const accel = 1.0
var currentSpeed = 0.0
var LEAN_AMOUNT = PI/6

var current_fire_mode: String:
	get:
		if equipped_gun:
			return equipped_gun.current_fire_mode
		else: 
			return ""
var ads_pos: Vector3
var hf_pos: Vector3
var grip_pos: Node3D
var handguard_pos: Node3D
var ads_accel: float
var default_fov: float = 75.0
var ads_fov: float
var fully_ads: bool = false
@onready var home_basis: Basis = waist.transform.basis
@warning_ignore("unsafe_method_access")
@onready var right_lean_basis: Basis = waist.transform.basis.rotated(Vector3.FORWARD, LEAN_AMOUNT)
@warning_ignore("unsafe_method_access")
@onready var left_lean_basis: Basis = waist.transform.basis.rotated(Vector3.FORWARD, -LEAN_AMOUNT)

var config = ConfigFile.new()
var both_eyes_open_ads: bool
var toggle_sprint: bool
var toggle_sprint_f: bool = false
var toggle_crouch: bool
var toggle_crouch_f: bool = false
var toggle_ads: bool
var toggle_lean: bool
var toggle_prone_f: bool = false
var toggle_inv_f: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if gun_scene1:
		equipped_gun = gun_scene1.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		#pick_up_gun(equipped_gun)
	if gun_scene2:
		shoulder_gun = gun_scene2.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		#pick_up_gun(shoulder_gun)
	
	var err = config.load("res://game_settings.cfg")
	if err == OK:
		for player in config.get_sections():
			both_eyes_open_ads = config.get_value(player, "both_eyes_open_ads")
			toggle_sprint = config.get_value(player, "toggle_sprint")
			toggle_crouch = config.get_value(player, "toggle_crouch")
			toggle_lean = config.get_value(player, "toggle_lean")
			toggle_ads = config.get_value(player, "toggle_ads")
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = NORMAL_SPEED
	Events.set_health.emit(health,max_health)
	$PlayerMotionStateMachine._active = true
	Events.fire_mode_changed.emit("")
	Events.ammo_count_changed.emit(0)
	Events.item_equipped.connect(_on_item_equipped)
	Events.item_dropped.connect(_on_item_dropped)
	Events.item_picked_up.connect(_on_item_picked_up)
	Events.item_removed.connect(_on_item_removed)
	Events.player_inventory_visibility.emit(toggle_inv_f)
	Events.set_health.emit(health,max_health)
	
	los_check_locations.append($HitBox/HeadBoneAttachment/eyes)
	los_check_locations.append($HitBox/RightFootBoneAttachment)
	los_check_locations.append($HitBox/LeftFootBoneAttachment)
	los_check_locations.append($center_mass)
	los_check_locations.append($HitBox/RightLowerArmBoneAttachment/r_hand)
	los_check_locations.append($HitBox/LeftLowerArmBoneAttachment/l_hand)
	
	ik_head.start()
	
	pov_rotation_node = chest
	

func _on_item_equipped(slot_name:String, item_equipped:ItemComponent):
	item_equipped.picked_up()
	match slot_name:
		"GunSlot1":
			gun_slot_1 = item_equipped.get_parent()
			move_gun_to_player_model(gun_slot_1)
		"GunSlot2":
			gun_slot_2 = item_equipped.get_parent()
			move_gun_to_player_model(gun_slot_2) 
		"BackpackSlot":
			item_equipped.picked_up()
			move_backpack_to_anchor(item_equipped.get_parent())
		"ArmorSlot":
			item_equipped.picked_up()
			move_armor_to_anchor(item_equipped.get_parent())
	pass
	
func _on_item_picked_up(item_picked_up:ItemComponent):
	var item_parent = item_picked_up.get_parent()
	item_picked_up.picked_up()
	item_parent.reparent(self,false)
	item_parent.visible = false
	
func _on_item_removed(slot_name, item_picked_up:ItemComponent):
	var item_parent = item_picked_up.get_parent()
	if item_parent is Gun:
		if item_parent == equipped_gun:
			stop_arms_ik()
			equipped_gun = null	
		if item_parent == gun_slot_1:
			gun_slot_1 = null	
		if item_parent == gun_slot_2:
			gun_slot_2 = null	

func _on_item_dropped(item_equipped:ItemComponent):
	drop_item(item_equipped)
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
		@warning_ignore("unsafe_property_access")
		hf_pos = -gun.get_node("HipFire").position
		@warning_ignore("unsafe_property_access")
		ads_pos = -gun.get_node("ADS").position
		@warning_ignore("unsafe_property_access")
		grip_pos = gun.get_node("Grip")
		@warning_ignore("unsafe_property_access")
		handguard_pos = gun.get_node("Handguard")
		ads_accel = gun.gun_stats.ads_accel
		ads_fov = gun.gun_stats.ads_fov
		gun.position = hf_pos
		gun.fired.connect(_on_gun_fired)
		gun.reloaded.connect(_on_gun_reloaded)
		current_fire_mode = gun.current_fire_mode
		gun.reparent(cam,false)
		Events.fire_mode_changed.emit(gun.current_fire_mode)
		Events.ammo_count_changed.emit(gun.magazine)
		gun.visible = true
		start_arms_ik(gun.Right_Hand, gun.Right_Fingers, gun.Left_Hand, gun.Left_Fingers)
		

func move_gun_to_shoulder(gun:Gun):
	shoulder_gun = gun
	if gun:
		gun.reparent(shoulder_anchor)
		gun.transform = Transform3D.IDENTITY
		gun.rotate_x(-PI/2)
		gun.visible = true
		pass

func move_armor_to_anchor(armor:Node3D):
	if armor:
		armor.reparent(armor_anchor)
		armor.transform = Transform3D.IDENTITY
		armor.visible = true
		pass
		
func move_backpack_to_anchor(backpack:Node3D):
	if backpack:
		backpack.reparent(backpack_anchor)
		backpack.transform = Transform3D.IDENTITY
		backpack.visible = true

func drop_equipped_gun():
	if equipped_gun:
		equipped_gun.fired.disconnect(_on_gun_fired)
		equipped_gun.reloaded.disconnect(_on_gun_reloaded)
		Events.fire_mode_changed.emit("")
		Events.ammo_count_changed.emit(0)
		drop_item(equipped_gun.get_node("ItemComponent"))
#		if gun_in_slot(equipped_gun, gun_slot_1):
#			gun_slot_1.remove_item()
#		elif gun_in_slot(equipped_gun, gun_slot_2):
#			gun_slot_2.remove_item()			
		equipped_gun = null
		stop_arms_ik()

func drop_item(item_comp:ItemComponent):
	var item_parent = item_comp.get_parent()
#	var item_parent_global_pos = drop_location.global_position
	item_parent.reparent(self.get_parent())
	item_comp.dropped()
	item_parent.visible = true
	item_parent.global_position = drop_location.global_position
	if item_parent is Gun:
		if item_parent == gun_slot_1:
			gun_slot_1 = null
		if item_parent == gun_slot_2:
			gun_slot_2 = null
		if item_parent == equipped_gun:
			equipped_gun = null
		if item_parent == shoulder_gun:
			shoulder_gun = null

#realtime inputs - movement stuff
func _physics_process(delta):
	if !toggle_inv_f:
		if equipped_gun:
			# Handle Shooting
			if can_shoot():
				if current_fire_mode == "auto":
					if Input.is_action_pressed("shoot"):
						shoot()
				elif current_fire_mode == "semi":
					if Input.is_action_just_pressed("shoot"):
						shoot()
			
			if Input.is_action_just_pressed("reload"):
				reload()
				
			#handle ADS
			if shouldAds():
				if (equipped_gun.transform.origin - ads_pos).length() < 0.001:
					fully_ads = true
				else:
					if both_eyes_open_ads:
						equipped_gun.make_transparent()
					equipped_gun.transform.origin = equipped_gun.transform.origin.lerp(ads_pos, ads_accel)
					cam.fov = lerp(cam.fov, ads_fov, ads_accel)
			else:
				fully_ads = false
				if both_eyes_open_ads:
					equipped_gun.make_opaque()
				if equipped_gun.transform.origin != hf_pos:
					equipped_gun.transform.origin = equipped_gun.transform.origin.lerp(hf_pos, ads_accel)
					cam.fov = lerp(cam.fov, default_fov, ads_accel)
		
		#Handle Lean
		var slr = shouldLeanRight()
		var sll = shouldLeanLeft()
		if slr:
			waist.basis = Quaternion(waist.basis).slerp(Quaternion(right_lean_basis),0.5)
		elif sll:
			waist.basis = Quaternion(waist.basis).slerp(Quaternion(left_lean_basis),0.5)
		else:
			waist.basis = Quaternion(waist.basis).slerp(Quaternion(home_basis),0.5)
		
		#handle use hint
		if use_ray.is_colliding():
				var col = use_ray.get_collider()
				var ic = col.get_node("ItemComponent")
				if ic:
					Events.pickup_helper_visibility.emit(true)
				elif col.has_method("use"):
					Events.use_helper_visibility.emit(true)
				else:
					Events.use_helper_visibility.emit(false)
					Events.pickup_helper_visibility.emit(false)
		else:
			Events.use_helper_visibility.emit(false)
			Events.pickup_helper_visibility.emit(false)

var toggle_ads_f: bool = false
func shouldAds() -> bool:
	if toggle_ads:
		if Input.is_action_just_pressed("ads"):
			toggle_ads_f = !toggle_ads_f
		return toggle_ads_f
	else:
		return Input.is_action_pressed("ads")

var toggle_lean_l_f: bool = false
var toggle_lean_r_f: bool = false
func shouldLeanRight() -> bool:
	if !toggle_lean:
		return Input.is_action_pressed("leanRight")
	else:
		if Input.is_action_just_pressed("leanRight"):
			toggle_lean_r_f = !toggle_lean_r_f
			toggle_lean_l_f = false
		return toggle_lean_r_f

func  shouldLeanLeft() -> bool:
	if !toggle_lean:
		return Input.is_action_pressed("leanLeft")
	else:
		if Input.is_action_just_pressed("leanLeft"):
			toggle_lean_l_f = !toggle_lean_l_f
			toggle_lean_r_f = false
		return toggle_lean_l_f

		
func can_shoot() -> bool:
	return is_on_floor() #and !isSprinting()

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	else:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#legacyMouse(event)
			transformMouse(event)
		elif event.is_action_pressed("toggleFireMode"):
			if equipped_gun.has_method("toggle_fire_mode"):
				var fire_mode = equipped_gun.toggle_fire_mode()
				Events.fire_mode_changed.emit(fire_mode)
				current_fire_mode = fire_mode
		elif event.is_action_pressed("use"):
			if use_ray.is_colliding():
				var col = use_ray.get_collider()
				var col_icomp = col.get_node("ItemComponent")
				if col_icomp:
					Events.player_inventory_try_pickup.emit(col_icomp)
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
	Events.player_inventory_visibility.emit(toggle_inv_f)
	if toggle_inv_f:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Events.player_inventory_closed.emit(self)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func transformMouse(event: InputEventMouse):
	rotate_y(-event.relative.x * mouse_sensitivity)
	pov_rotation_node.rotate_x(-event.relative.y * mouse_sensitivity)
	pov_rotation_node.rotation.x = clampf(pov_rotation_node.rotation.x, -deg_to_rad(85), deg_to_rad(85))

func legacyMouse(event: InputEventMouse):
	rotation.y -= event.relative.x / mouseSensibility
	pov_rotation_node.rotation.x -= event.relative.y / mouseSensibility
	pov_rotation_node.rotation.x = clamp(pov_rotation_node.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
	mouse_relative_x = clamp(event.relative.x, -50, 50)
	mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	equipped_gun.fireGun()
	
func reload():
	equipped_gun.reloadGun()


func _on_gun_fired(recoil:Vector2):
	Events.ammo_count_changed.emit(equipped_gun.magazine)
	var scaled_recoil = scale_recoil(recoil)
#	#flip the mapping so that recoil.y moves the camera vertically	
	rotate_y(scaled_recoil.x)
	pov_rotation_node.rotate_x(scaled_recoil.y)
	pov_rotation_node.rotation.x = clampf(pov_rotation_node.rotation.x, -deg_to_rad(80), deg_to_rad(80))
	#legacy - We don't want to manually manipulate the rotations
#	#flip the mapping so that recoil.y moves the camera vertically
#	$Head/Camera3d.rotation.y += recoil.x
#	$Head/Camera3d.rotation.x += recoil.y

func scale_recoil(recoil:Vector2) -> Vector2:
	var factor = 1.0
	if fully_ads:
		factor -= .2
	
	var current_state = pmsm.current_state.name
	match current_state:
		"Crouching":
			factor -= .2
		"CrouchWalking", "Standing":
			factor -= .1
		"Prone":
			factor -= .4

	return recoil * factor
	
func _on_gun_reloaded():
	Events.ammo_count_changed.emit(equipped_gun.magazine)	

func _on_area_3d_took_damage(damage):
	health-=damage
	Events.set_health.emit(health,max_health)
	if health < 0:
		print("Game Over")
		
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
