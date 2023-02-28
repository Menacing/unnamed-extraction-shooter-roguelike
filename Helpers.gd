extends Node

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
