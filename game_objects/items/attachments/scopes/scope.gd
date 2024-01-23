extends Item3D
class_name Scope

@onready var eye_position:Node3D = $eye_position

func get_ads_offset() -> Vector3:
	return eye_position.position
