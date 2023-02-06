extends Node3D

signal fired
signal reloaded

@export var rpm: int = 600
@export var magazineSize: int = 30
@export var magazine: int = magazineSize
@onready var gun_mat: BaseMaterial3D = $gun/Node_15/gun/barrel/Cube.get_active_material(0)
@export var _bullet_scene : PackedScene
@export var base_recoil: Vector2 = Vector2(0,0.025)
@export var recoil_variability = Vector2(0.025, 0.0125)
@export var fire_modes = ["semi","auto"]
@export var ads_accel = 0.3
@export var ads_fov = 50.0
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
		var muzzle = $gun/Muzzle
		
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

var is_transparent: bool = false
func make_transparent():
	if !is_transparent:
		gun_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
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
