@tool
class_name GeoBallisticMover
extends GeoBallisticSolid

var base_transform: Transform3D
var offset_transform: Transform3D
var target_transform: Transform3D
var rotation_offset: Vector3

var speed := 1.0

var moved:bool = false

func update_properties() -> void:
	super()
	if 'translation' in properties:
		offset_transform.origin = properties.translation

	if 'rotation' in properties:
		offset_transform.basis = offset_transform.basis.rotated(Vector3.RIGHT, properties.rotation.x)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.UP, properties.rotation.y)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.FORWARD, properties.rotation.z)

	if 'scale' in properties:
		offset_transform.basis = offset_transform.basis.scaled(properties.scale)

	if 'speed' in properties:
		speed = properties.speed
	
	if 'rotation_offset' in properties:
		rotation_offset = properties.rotation_offset

func _process(delta: float) -> void:
	transform = transform.interpolate_with(target_transform, speed * delta)

func _ready() -> void:
	super()
	self.transform.origin += rotation_offset
	for child in get_children():
		if child is Node3D:
			child.transform.origin -= rotation_offset
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
