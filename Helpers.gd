extends Node

func _ready():
	randomize()

func slow_rotate_to_point(node:Node3D, point:Vector3, rotation_speed:float, delta:float):
	var T=node.global_transform.looking_at(point, Vector3(0,1,0))
	var sourceQ = Quaternion(node.global_transform.basis)
	var destQ = Quaternion(T.basis)
	var calc_speed = rotation_speed*delta
	var resultQ = sourceQ.slerp(destQ,calc_speed)
	node.global_transform.basis = Basis(resultQ)

func slow_rotate_to_point_flat(node:Node3D, point:Vector3, rotation_speed:float, delta:float):
	var flattened_target:Vector3 = Vector3(point.x, node.global_transform.origin.y, point.z)
	slow_rotate_to_point(node, flattened_target, rotation_speed, delta)

func random_angle_deviation_moa(node:Node3D, max_vert_moa:float, max_hor_moa:float):
	var vert_moa = randf_range(-max_vert_moa/2, max_vert_moa/2)
	var hor_moa = randf_range(-max_hor_moa/2, max_hor_moa/2)
	node.rotate_x(moa_to_rad(vert_moa))
	node.rotate_y(moa_to_rad(hor_moa))
	
func moa_to_rad(moa:float) -> float:
	return moa * 0.00029
