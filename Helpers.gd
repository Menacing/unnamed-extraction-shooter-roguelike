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

#Only call during _physics_process
func los_to_point(target:Node3D, sources:Array[Node3D], threshold:float, exclusions:Array[RID] = []) -> bool:
	var num_sources = sources.size()
	var num_los = 0.0
	var space_state = target.get_world_3d().direct_space_state
	if space_state:
		var target_global_pos = target.global_position
		for source in sources:
			var query = PhysicsRayQueryParameters3D.create(source.global_transform.origin,\
				target_global_pos)
			if exclusions.size() > 0:
				query.exclude = exclusions
			var result = space_state.intersect_ray(query)
			if result.is_empty():
				num_los += 1.0
			pass
		if (num_los/num_sources > threshold):
			return true
		else:
			return false
	else:
		return false

func get_all_collision_object_3d_recursive(node: Node) -> Array[RID]:
	var list:Array[RID] = []
	if node is CollisionObject3D :
		list.append(node.get_rid())
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if child.get_child_count() > 0:
			var child_cols = get_all_collision_object_3d_recursive(child)
			list.append_array(child_cols)
	return list