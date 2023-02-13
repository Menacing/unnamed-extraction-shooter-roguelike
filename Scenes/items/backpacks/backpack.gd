extends RigidBody3D
class_name Backpack

enum Size {
	NONE,
	SMALL,
	MEDIUM,
	LARGE
}

@export var backpack_size:Size = Size.NONE
