extends Node3D

signal fired
signal reloaded

@export var magazineSize = 30
@export var magazine = magazineSize

@onready var gunRay = $RayCast3d as RayCast3D
@export var _bullet_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fireGun():
	if magazine > 0:
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
	magazine = magazineSize
	$AnimationPlayer.play("reload")
	reloaded.emit()
