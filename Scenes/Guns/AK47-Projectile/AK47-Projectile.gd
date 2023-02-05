extends Node3D

signal fired
signal reloaded

@export var rpm: int = 600
@export var magazineSize: int = 30
@export var magazine: int = magazineSize
@onready var gunRay = $quick_AK47_2/RayCast3D as RayCast3D
@export var _bullet_scene : PackedScene
@export var base_recoil: Vector2 = Vector2(0,0.1)
@export var recoil_variability = Vector2(0.1, 0.05)
@export var fire_modes = ["semi","auto"]
var current_fire_mode_i = 0
var current_fire_mode = fire_modes[current_fire_mode_i]

var reloading: bool = false
var rng: RandomNumberGenerator
@onready var fire_timer = $FireTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.connect("timeout", reloaded_callback)
	rng = RandomNumberGenerator.new()
	fire_timer.wait_time = 60.0/rpm


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func canFire() -> bool:
	if magazine > 0 and !reloading and fire_timer.time_left == 0:
		return true
	else:
		return false

func fireGun():
	if canFire():
		var muzzle = $quick_AK47_2/Muzzle
		
		var shoot_origin = muzzle.global_transform.origin
		
		var bulletInst = _bullet_scene.instantiate()
		bulletInst.set_as_top_level(true)		
		get_parent().add_child(bulletInst)
		bulletInst.global_transform.origin = shoot_origin
		
		magazine -= 1
		$AnimationPlayer.play("fire")
		fire_timer.start()
		fired.emit(generate_recoil())
	else:
		#click
		pass

func reloadGun():
	$ReloadTimer.start()
	reloading = true
	$AnimationPlayer.play("reload")
	
func reloaded_callback():
	magazine = magazineSize
	$ReloadTimer.stop()
	reloading = false
	reloaded.emit()
	
func generate_recoil() -> Vector2:
	return Vector2(base_recoil.x + rng.randf_range(-recoil_variability.x, recoil_variability.x), \
		base_recoil.y + rng.randf_range(-recoil_variability.y, recoil_variability.y))

func toggle_fire_mode() -> String:
	var next_i = current_fire_mode_i + 1
	if next_i > fire_modes.size() - 1:
		current_fire_mode_i = 0
	else:
		current_fire_mode_i = next_i
	current_fire_mode = fire_modes[current_fire_mode_i]
	return current_fire_mode
