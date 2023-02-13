extends CharacterBody3D
class_name Player

@export var gun_scene1: PackedScene
@export var gun_scene2: PackedScene
@export var max_health:float = 100.0
@onready var health:float = max_health
var equipped_gun:Gun
var shoulder_gun:Gun
@onready var cam = $Head/Camera3d as Camera3D
@onready var head = $Head as Node3D
@onready var life_bar = $Head/Camera3d/CanvasLayer/LifeBar as ProgressBar
@onready var pmsm = $PlayerMotionStateMachine
@onready var use_ray = $Head/Camera3d/UsePointer
@onready var inv_ui = $Head/Camera3d/ui/CanvasLayer
@onready var inventory = $Head/Camera3d/ui/CanvasLayer/inventory_canvas
@onready var use_helper = $Head/Camera3d/CanvasLayer/use_helper
@onready var pickup_helper = $Head/Camera3d/CanvasLayer/pickup_helper
@onready var gun_slot_1:InventorySpecialSlot = $Head/Camera3d/ui/CanvasLayer/inventory_canvas/gun_1
@onready var gun_slot_2:InventorySpecialSlot = $Head/Camera3d/ui/CanvasLayer/inventory_canvas/gun_2
@onready var shoulder_anchor:Node3D = $player_default_mesh/shoulder_anchor

@onready var backpack_slot:InventorySpecialSlot = $Head/Camera3d/ui/CanvasLayer/inventory_canvas/backpack_slot
var mouseSensibility = 1200
var mouse_sensitivity = 0.005
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
		return equipped_gun.current_fire_mode
var ads_pos: Vector3
var hf_pos: Vector3
var grip_pos: Vector3
var handguard_pos: Vector3
var ads_accel: float
var default_fov: float = 75.0
var ads_fov: float
var fully_ads: bool = false
@onready var home_basis: Basis = head.transform.basis
@warning_ignore("unsafe_method_access")
@onready var right_lean_basis: Basis = head.transform.basis.rotated(Vector3.FORWARD, LEAN_AMOUNT)
@warning_ignore("unsafe_method_access")
@onready var left_lean_basis: Basis = head.transform.basis.rotated(Vector3.FORWARD, -LEAN_AMOUNT)

var config = ConfigFile.new()
var both_eyes_open_ads: bool
var toggle_sprint: bool
var toggle_sprint_f: bool = false
var toggle_crouch: bool
var toggle_crouch_f: bool = false
var toggle_ads: bool
var toggle_lean: bool
var toggle_prone_f: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if gun_scene1:
		equipped_gun = gun_scene1.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		pick_up_gun(equipped_gun)
	if gun_scene2:
		shoulder_gun = gun_scene2.instantiate()
		#TODO: Pull these from the packed scene instead of being hardcoded
		pick_up_gun(shoulder_gun)
	
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
	life_bar.value = health/max_health * health
	$PlayerMotionStateMachine._active = true
	inv_ui.visible = false
	
func pick_up_gun(world_gun:Gun):
	var idata1 = gun_slot_1.get_item_data(true)
	var idata2 = gun_slot_2.get_item_data(true)
	if idata1.size() == 0 or idata2.size() == 0:
		owner.remove_child(world_gun)
		#self.add_child(world_gun)
		world_gun.set_owner(self)
		if !equipped_gun:
			move_gun_to_hands(world_gun)
		elif !shoulder_gun:
			move_gun_to_shoulder(world_gun)
		var ic:ItemComponent = world_gun.get_node("ItemComponent")
		ic.picked_up()
		var idata = ic.idata
		if idata1.size() == 0:
			gun_slot_1.add_item(idata)
		elif idata2.size() == 0:
			gun_slot_2.add_item(idata)

func pick_up_backpack(world_backpack:Backpack):
	var idata = backpack_slot.get_item_data(true)
	if idata.size() == 0:
		owner.remove_child(world_backpack)
		world_backpack.set_owner(self)
		var ic:ItemComponent = world_backpack.get_node("ItemComponent")
		ic.picked_up()
		var wdata = ic.idata
		backpack_slot.add_item(wdata)
		inventory.set_backpack_size(world_backpack.backpack_size)
	
func move_gun_to_hands(gun:Gun):
	equipped_gun = gun
	if gun:	
		shoulder_anchor.remove_child(gun)
		gun.transform = Transform3D.IDENTITY	
		@warning_ignore("unsafe_property_access")
		hf_pos = -gun.get_node("HipFire").position
		@warning_ignore("unsafe_property_access")
		ads_pos = -gun.get_node("ADS").position
		@warning_ignore("unsafe_property_access")
		grip_pos = -gun.get_node("Grip").position
		@warning_ignore("unsafe_property_access")
		handguard_pos = -gun.get_node("Handguard").position
		ads_accel = gun.gun_stats.ads_accel
		ads_fov = gun.gun_stats.ads_fov
		gun.position = hf_pos
		gun.fired.connect(_on_gun_fired)
		gun.reloaded.connect(_on_gun_reloaded)
		current_fire_mode = gun.current_fire_mode
		cam.add_child(gun)
		gun.set_owner(cam)
		$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine
		$Head/Camera3d/CanvasLayer/FireMode.text = "%s" % gun.current_fire_mode

func move_gun_to_shoulder(gun:Gun):
	shoulder_gun = gun
	if gun:
		cam.remove_child(gun)
		gun.transform = Transform3D.IDENTITY
		#gun.transform.origin = shoulder_anchor.transform.origin
		gun.rotate_x(-PI/2)
		shoulder_anchor.add_child(gun)

func drop_gun():
	if equipped_gun:
		var gun_global_pos = equipped_gun.global_position
		equipped_gun.fired.disconnect(_on_gun_fired)
		equipped_gun.reloaded.disconnect(_on_gun_reloaded)
		cam.remove_child(equipped_gun)
		equipped_gun.position = gun_global_pos
		get_parent().add_child(equipped_gun)
		$Head/Camera3d/CanvasLayer/AmmoCount.text = ""
		$Head/Camera3d/CanvasLayer/FireMode.text = ""
		equipped_gun.get_node("ItemComponent").dropped()
		if gun_in_slot(equipped_gun, gun_slot_1):
			gun_slot_1.remove_item()
		elif gun_in_slot(equipped_gun, gun_slot_2):
			gun_slot_2.remove_item()			
		equipped_gun = null
		

#realtime inputs - movement stuff
func _physics_process(delta):
	if !inv_ui.visible:
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
			head.basis = Quaternion(head.basis).slerp(Quaternion(right_lean_basis),0.5)
		elif sll:
			head.basis = Quaternion(head.basis).slerp(Quaternion(left_lean_basis),0.5)
		else:
			head.basis = Quaternion(head.basis).slerp(Quaternion(home_basis),0.5)
		
		#handle use hint
		if use_ray.is_colliding():
				var col = use_ray.get_collider()
				var ic = col.get_node("ItemComponent")
				if ic:
					pickup_helper.visible = true
				elif col.has_method("use"):
					use_helper.visible = true
				else:
					use_helper.visible = false
					pickup_helper.visible = false
		else:
			use_helper.visible = false
			pickup_helper.visible = false

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
				$Head/Camera3d/CanvasLayer/FireMode.text = fire_mode
				current_fire_mode = fire_mode
		elif event.is_action_pressed("use"):
			if use_ray.is_colliding():
				var col = use_ray.get_collider()
				if col is Gun:
					print("you found a gun!")
					pick_up_gun(col)
				elif col is Backpack:
					print("you found a backpack!")
					pick_up_backpack(col)
				elif col.has_method("use"):
					col.use(self)
		elif event.is_action_pressed("dropGun"):
			drop_gun()
		elif event.is_action_pressed("equipGunSlot1"):
			if !gun_in_slot(equipped_gun, gun_slot_1):
				var old_gun = equipped_gun
				move_gun_to_hands(shoulder_gun)
				move_gun_to_shoulder(old_gun)
		elif event.is_action_pressed("equipGunSlot2"):
			if !gun_in_slot(equipped_gun, gun_slot_2):
				var old_gun = equipped_gun
				move_gun_to_hands(shoulder_gun)
				move_gun_to_shoulder(old_gun)

func gun_in_slot(gun:Gun, gun_slot:InventorySpecialSlot) -> bool:
		var idata = gun_slot.get_item_data(true)
		var ret = (idata and gun and idata["node_id"] == gun.get_instance_id())
		return ret
		
func toggle_inventory():
	inv_ui.visible = !inv_ui.visible
	if inv_ui.visible:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		var cons = Events.inventory_closed.get_connections()
		Events.inventory_closed.emit(self)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func transformMouse(event: InputEventMouse):
	rotate_y(-event.relative.x * mouse_sensitivity)
	$Head/Camera3d.rotate_x(-event.relative.y * mouse_sensitivity)
	$Head/Camera3d.rotation.x = clampf($Head/Camera3d.rotation.x, -deg_to_rad(85), deg_to_rad(85))

func legacyMouse(event: InputEventMouse):
	rotation.y -= event.relative.x / mouseSensibility
	$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
	$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
	mouse_relative_x = clamp(event.relative.x, -50, 50)
	mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	equipped_gun.fireGun()
	
func reload():
	equipped_gun.reloadGun()


func _on_gun_fired(recoil:Vector2):
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % equipped_gun.magazine
	var scaled_recoil = scale_recoil(recoil)
#	#flip the mapping so that recoil.y moves the camera vertically	
	rotate_y(scaled_recoil.x)
	$Head/Camera3d.rotate_x(scaled_recoil.y)
	$Head/Camera3d.rotation.x = clampf($Head/Camera3d.rotation.x, -deg_to_rad(80), deg_to_rad(80))
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
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % equipped_gun.magazine
	

func _on_area_3d_took_damage(damage):
	health-=damage
	life_bar.value = health/max_health*health
	if health < 0:
		print("Game Over")
