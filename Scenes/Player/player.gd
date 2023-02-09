extends CharacterBody3D

@export var gun_scene: PackedScene
@export var max_health:float = 100.0
@onready var health:float = max_health
var gun: Node3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var head = $Head as Node3D
@onready var life_bar = $Head/Camera3d/CanvasLayer/LifeBar as ProgressBar
@onready var pmsm = $PlayerMotionStateMachine
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

var current_fire_mode: String
var ads_pos: Vector3
var hf_pos: Vector3
var grip_pos: Vector3
var handguard_pos: Vector3
var ads_accel: float
var default_fov: float = 75.0
var ads_fov: float
var fully_ads: bool = false
@onready var home_basis: Basis = head.transform.basis
@onready var right_lean_basis: Basis = head.transform.basis.rotated(Vector3.FORWARD, LEAN_AMOUNT)
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
	gun = gun_scene.instantiate()
	#TODO: Pull these from the packed scene instead of being hardcoded
	gun.magazineSize = 30
	hf_pos = -gun.get_node("HipFire").position
	ads_pos = -gun.get_node("ADS").position
	grip_pos = -gun.get_node("Grip").position
	handguard_pos = -gun.get_node("Handguard").position
	ads_accel = gun.ads_accel
	ads_fov = gun.ads_fov
	gun.position = hf_pos
	gun.fired.connect(_on_gun_fired)
	gun.reloaded.connect(_on_gun_reloaded)
	current_fire_mode = gun.current_fire_mode
	$Head/Camera3d.add_child(gun)
	
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
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazineSize
	$Head/Camera3d/CanvasLayer/FireMode.text = "%s" % gun.current_fire_mode
	life_bar.value = health/max_health * health
	$PlayerMotionStateMachine._active = true

#realtime inputs - movement stuff
func _physics_process(delta):
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
		if (gun.transform.origin - ads_pos).length() < 0.001:
			fully_ads = true
		else:
			if both_eyes_open_ads:
				gun.make_transparent()
			gun.transform.origin = gun.transform.origin.lerp(ads_pos, ads_accel)
			Cam.fov = lerp(Cam.fov, ads_fov, ads_accel)
	else:
		fully_ads = false
		if both_eyes_open_ads:
			gun.make_opaque()
		if gun.transform.origin != hf_pos:
			gun.transform.origin = gun.transform.origin.lerp(hf_pos, ads_accel)
			Cam.fov = lerp(Cam.fov, default_fov, ads_accel)
	
	#Handle Lean
	var slr = shouldLeanRight()
	var sll = shouldLeanLeft()
	if slr:
		head.basis = Quaternion(head.basis).slerp(Quaternion(right_lean_basis),0.5)
	elif sll:
		head.basis = Quaternion(head.basis).slerp(Quaternion(left_lean_basis),0.5)
	else:
		head.basis = Quaternion(head.basis).slerp(Quaternion(home_basis),0.5)		
	


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
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#legacyMouse(event)
		transformMouse(event)
	elif event.is_action_pressed("toggleFireMode"):
		if gun.has_method("toggle_fire_mode"):
			var fire_mode = gun.toggle_fire_mode()
			$Head/Camera3d/CanvasLayer/FireMode.text = fire_mode
			current_fire_mode = fire_mode


func transformMouse(event: InputEventMouse):
	rotate_y(-event.relative.x * mouse_sensitivity)
	$Head/Camera3d.rotate_x(-event.relative.y * mouse_sensitivity)
	$Head/Camera3d.rotation.x = clampf($Head/Camera3d.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func legacyMouse(event: InputEventMouse):
	rotation.y -= event.relative.x / mouseSensibility
	$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
	$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
	mouse_relative_x = clamp(event.relative.x, -50, 50)
	mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	gun.fireGun()
	
func reload():
	gun.reloadGun()


func _on_gun_fired(recoil:Vector2):
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine
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
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine
	

func _on_area_3d_took_damage(damage):
	health-=damage
	life_bar.value = health/max_health*health
	if health < 0:
		print("Game Over")
