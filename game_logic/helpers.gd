extends Node

func _ready():
	randomize()
	
func get_cell_size() -> int:
	return 32

func slow_rotate_to_point(node:Node3D, point:Vector3, rotation_speed:float, delta:float):
	var T:Transform3D=node.global_transform.looking_at(point, Vector3(0,1,0))
	var sourceQ:Quaternion = Quaternion(node.global_transform.basis)
	var destQ:Quaternion = Quaternion(T.basis)
	var calc_speed:float = rotation_speed*delta
	var resultQ:Quaternion = sourceQ.slerp(destQ,calc_speed)
	node.global_transform.basis = Basis(resultQ)

func slow_rotate_to_point_flat(node:Node3D, point:Vector3, rotation_speed:float, delta:float):
	var flattened_target:Vector3 = Vector3(point.x, node.global_transform.origin.y, point.z)
	slow_rotate_to_point(node, flattened_target, rotation_speed, delta)

func random_angle_deviation_moa(node:Node3D, max_vert_moa:float, max_hor_moa:float):
	var vert_moa:float = randf_range(-max_vert_moa/2, max_vert_moa/2)
	var hor_moa:float = randf_range(-max_hor_moa/2, max_hor_moa/2)
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
		var target_global_pos:Vector3 = target.global_position
		for source in sources:
			var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(source.global_transform.origin,\
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
		var child:Node = node.get_child(i)
		if child.get_child_count() > 0:
			var child_cols:Array[RID] = get_all_collision_object_3d_recursive(child)
			list.append_array(child_cols)
	return list
	
func gddeg_to_compass_deg(unnormal_deg:int) -> int:
	var normal_deg = 0 
	if unnormal_deg < 0:
		normal_deg = -unnormal_deg
	elif unnormal_deg > 0:
		normal_deg = 360 - (unnormal_deg % 360)
	return normal_deg % 360

func get_control_in_group_with_method_at_position(cursor_pos:Vector2, group_name:String, method_name:String) -> Control:
	var containers = get_tree().get_nodes_in_group(group_name)
	for c in containers:
		if c is Control and c.get_global_rect().has_point(cursor_pos):
			if c.has_method(method_name):
				return c
	return null

func duplicate_node_by_id(node_id: int) -> Node:
	# Retrieve the node using the ID
	var original_node:Node 
	if node_id != 0:
		original_node = instance_from_id(node_id)
	
	# If the node doesn't exist, return null
	if original_node == null:
		return null
	
	# Duplicate the node
	var duplicated_node = original_node.duplicate()
	
	# Return the duplicated node
	return duplicated_node

func force_parent(child:Node, parent:Node):
	if child.get_parent():
		child.get_parent().remove_child(child)
	parent.add_child(child)
	child.set_owner(parent)


func get_aabb_of_node(node:Node):
	var aabb = AABB()
	if node.has_method("get_aabb") and node.visible:
		aabb = node.get_aabb()
	elif node is CollisionShape3D:
		var shape:Shape3D = node.shape
		var array_mesh:ArrayMesh = shape.get_debug_mesh()
		aabb = array_mesh.get_aabb()
	for child in node.get_children():
		aabb = aabb.merge(get_aabb_of_node(child))
		
	print_debug("returning aabb for node:" + node.name + " with aabb " + str(aabb))
	return aabb

func get_all_mesh_nodes(node) -> Array[MeshInstance3D]:
	var mesh_nodes:Array[MeshInstance3D] =[]
	for N in node.get_children():
		if N is MeshInstance3D:
			mesh_nodes.append(N)
		if N.get_child_count() > 0:
			mesh_nodes.append_array(get_all_mesh_nodes(N))
		else:
			# Do something
			pass
	return mesh_nodes
