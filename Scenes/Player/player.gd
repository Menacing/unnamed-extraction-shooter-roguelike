extends CharacterBody3D

@export var gun_scene: PackedScene
var gun: Node3D
@onready var Cam = $Head/Camera3d as Camera3D
var mouseSensibility = 1200
var mouse_sensitivity = 0.005
var mouse_relative_x = 0
var mouse_relative_y = 0
const NORMAL_SPEED = 5.0
const CROUCH_SPEED = 2.5
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
var currentSpeed = 0.0

var current_fire_mode: String
var ads_pos: Vector3
var hf_pos: Vector3
var ads_accel: float
var default_fov: float = 75.0
var ads_fov: float
var fully_ads: bool = false

var config = ConfigFile.new()
var both_eyes_open_ads: bool
var toggle_sprint: bool
var toggle_crouch: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	gun = gun_scene.instantiate()
	#TODO: Pull these from the packed scene instead of being hardcoded
	gun.magazineSize = 30
	hf_pos = -gun.get_node("HipFire").position
	ads_pos = -gun.get_node("ADS").position
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
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = NORMAL_SPEED
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazineSize
	$Head/Camera3d/CanvasLayer/FireMode.text = "%s" % gun.current_fire_mode

#realtime inputs - movement stuff
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	if Input.is_action_pressed("ads"):
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
	
	#Set Speed based on if is sprinting or crouching
	if isSprinting():
		currentSpeed = RUN_SPEED
		$CollisionShape3d.get_shape().set_height(2)
	elif isCrouching():
		currentSpeed = CROUCH_SPEED
		$CollisionShape3d.get_shape().set_height(1)
	else:
		currentSpeed = NORMAL_SPEED
		$CollisionShape3d.get_shape().set_height(2)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()

var toggle_sprint_f: bool = false
func isSprinting() -> bool:
	if toggle_sprint:
		if Input.is_action_just_pressed("sprint"):
			toggle_sprint_f = !toggle_sprint_f
		return toggle_sprint_f
	else:
		return Input.is_action_pressed("sprint")
		
var toggle_crouch_f: bool = false
func isCrouching() -> bool:
	if toggle_crouch:
		if Input.is_action_just_pressed("crouch"):
			toggle_crouch_f = !toggle_crouch_f
		return toggle_crouch_f
	else:
		return Input.is_action_pressed("crouch")
		
func can_shoot() -> bool:
	return is_on_floor() and !isSprinting()

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
	if isCrouching():
		factor -= .2
	
	return recoil * factor
	
func _on_gun_reloaded():
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine
