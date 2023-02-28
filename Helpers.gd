extends Node

func slow_rotate_to_point(node:Node3D, point:Vector3, rotation_speed:float, delta:float):
	var T=node.global_transform.looking_at(point, Vector3(0,1,0))
	var sourceQ = Quaternion(node.global_transform.basis)
	var destQ = Quaternion(T.basis)
	var resultQ = sourceQ.slerp(destQ,rotation_speed*delta)
	node.global_transform.basis = Basis(resultQ)
