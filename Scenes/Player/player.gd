extends CharacterBody3D

@export var gun_scene: PackedScene
var gun
#@onready var gunRay = $Head/Camera3d/AK47/RayCast3d as RayCast3D
var gunRay: RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
#@export var _bullet_scene : PackedScene
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const NORMAL_SPEED = 5.0
const CROUCH_SPEED = 2.5
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
var currentSpeed = 0.0
var sprintToggle:bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	gun = gun_scene.instantiate()
	#TODO: Pull these from the packed scene instead of being hardcoded
	gun.magazineSize = 30
	gun.position = Vector3(0.213,-0.233, -0.216)
	gun.fired.connect(_on_gun_fired)
	gun.reloaded.connect(_on_gun_reloaded)
	$Head/Camera3d.add_child(gun)
	gunRay = gun.get_node("quick_AK47_2/RayCast3D") 
	
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = NORMAL_SPEED
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazineSize

#realtime inputs - movement stuff
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
	
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

func isSprinting():
	var toggleSprintEnabled = false
	if toggleSprintEnabled:
		return false
	else:
		return Input.is_action_pressed("sprint")
		
func isCrouching():
	var toggleCrouchEnabled = false
	if toggleCrouchEnabled:
		return false
	else:
		return Input.is_action_pressed("crouch")

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	gun.fireGun()
	
func reload():
	gun.reloadGun()


func _on_gun_fired():
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine


func _on_gun_reloaded():
	$Head/Camera3d/CanvasLayer/AmmoCount.text = "%s" % gun.magazine
