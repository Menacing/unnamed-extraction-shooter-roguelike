extends State
class_name PlayerMotion

@export var collider_path:NodePath
var collider:CollisionShape3D

func enter():
	collider = get_node(collider_path)

func get_input_direction():
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	return input_direction
