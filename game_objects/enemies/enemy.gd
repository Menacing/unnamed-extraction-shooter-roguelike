extends CharacterBody3D
class_name Enemy

var fire_target:Node3D
var move_target:Node3D
@export var move_target_distance:float = 1.0

func has_fire_target() -> bool:
	if fire_target:
		return true
	else:
		return false

func has_move_target() -> bool:
	if fire_target:
		return true
	else:
		return false

func is_near_move_target() -> bool:
	
