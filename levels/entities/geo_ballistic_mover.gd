@tool
class_name GeoBallisticMover
extends GeoBallisticSolid

@export var base_transform: Transform3D
@export var offset_transform: Transform3D
@export var target_transform: Transform3D


@export var speed := 1.0

var moved:bool = false

func update_properties() -> void:
	super()
	if 'translation' in func_godot_properties:
		offset_transform.origin = func_godot_properties.translation

	if 'rotation' in func_godot_properties:
		offset_transform.basis = Basis()
		offset_transform.basis = offset_transform.basis.rotated(Vector3.RIGHT, func_godot_properties.rotation.x)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.UP, func_godot_properties.rotation.y)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.FORWARD, func_godot_properties.rotation.z)

	if 'scale' in func_godot_properties:
		offset_transform.basis = offset_transform.basis.scaled(func_godot_properties.scale)

	if 'speed' in func_godot_properties:
		speed = func_godot_properties.speed

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	transform = transform.interpolate_with(target_transform, speed * delta)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super()
	base_transform = transform
	target_transform = base_transform

func use(caller) -> void:
	moved = !moved
	play_motion()

func play_motion() -> void:
	if moved:
		target_transform = base_transform * offset_transform
	else:
		target_transform = base_transform
