extends CharacterBody3D

@export var func_godot_properties: Dictionary :
	get:
		return func_godot_properties # TODOConverter40 Non existent get function 
	set(new_properties):
		if(func_godot_properties != new_properties):
			func_godot_properties = new_properties
			update_properties()

var base_transform: Transform3D
var offset_transform: Transform3D
var target_transform: Transform3D

var speed := 1.0

func update_properties() -> void:
	if 'translation' in func_godot_properties:
		offset_transform.origin = func_godot_properties.translation

	if 'rotation' in func_godot_properties:
		offset_transform.basis = offset_transform.basis.rotated(Vector3.RIGHT, func_godot_properties.rotation.x)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.UP, func_godot_properties.rotation.y)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.FORWARD, func_godot_properties.rotation.z)

	if 'scale' in func_godot_properties:
		offset_transform.basis = offset_transform.basis.scaled(func_godot_properties.scale)

	if 'speed' in func_godot_properties:
		speed = func_godot_properties.speed

func _process(delta: float) -> void:
	transform = transform.interpolate_with(target_transform, speed * delta)

func _ready() -> void:
	base_transform = transform
	target_transform = base_transform

func use() -> void:
	play_motion()

func play_motion() -> void:
	target_transform = base_transform * offset_transform

func reverse_motion() -> void:
	target_transform = base_transform
