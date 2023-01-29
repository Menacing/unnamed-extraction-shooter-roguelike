extends Node3D

signal fired
signal reloaded

@export var magazineSize: int = 30
@export var magazine: int = magazineSize

@onready var gunRay = $RayCast3d as RayCast3D
@export var _bullet_scene : PackedScene

var reloading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.connect("timeout", reloaded_callback)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func canFire() -> bool:
	if magazine > 0 and !reloading:
		return true
	else:
		return false

func fireGun():
	if canFire():
		magazine -= 1
		$AnimationPlayer.play("fire")
		fired.emit()
		if not gunRay.is_colliding():
			return
		var bulletInst = _bullet_scene.instantiate() as Node3D
		bulletInst.set_as_top_level(true)
		get_parent().add_child(bulletInst)
		bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
		bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
		print(gunRay.get_collision_point())
		print(gunRay.get_collision_point()+gunRay.get_collision_normal())
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
	
