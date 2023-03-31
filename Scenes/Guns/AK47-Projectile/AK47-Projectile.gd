extends Gun

@export var magazineSize: int = 30
@export var magazine: int = magazineSize
@warning_ignore("unsafe_method_access")
@onready var gun_mat: BaseMaterial3D = $gun/Node_15/gun/barrel/Cube.get_active_material(0)

var current_fire_mode_i = 0

var reloading: bool = false
var rng: RandomNumberGenerator
@onready var fire_timer = $FireTimer

func _init():
	var ak_stats: GunStats = GunStats.new()
	ak_stats.rpm = 600
	ak_stats.ads_accel = 0.3
	ak_stats.ads_fov = 50.0
	ak_stats.base_recoil = Vector2(0,0.025)
	ak_stats.fire_modes = ["semi","auto"]
	ak_stats.recoil_variability = Vector2(0.025, 0.0125)
	ak_stats.moa = 5.0
	gun_stats = ak_stats
	

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.connect("timeout", reloaded_callback)
	rng = RandomNumberGenerator.new()
	fire_timer.wait_time = 60.0/gun_stats.rpm
	current_fire_mode = gun_stats.fire_modes[current_fire_mode_i]

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
		bulletInst.moa = gun_stats.moa
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
	return Vector2(gun_stats.base_recoil.x + rng.randf_range(-gun_stats.recoil_variability.x, gun_stats.recoil_variability.x), \
		gun_stats.base_recoil.y + rng.randf_range(-gun_stats.recoil_variability.y, gun_stats.recoil_variability.y))

func toggle_fire_mode() -> String:
	var next_i = current_fire_mode_i + 1
	if next_i > gun_stats.fire_modes.size() - 1:
		current_fire_mode_i = 0
	else:
		current_fire_mode_i = next_i
	current_fire_mode = gun_stats.fire_modes[current_fire_mode_i]
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

