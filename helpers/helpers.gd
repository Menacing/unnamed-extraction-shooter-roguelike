@tool
extends Node

func _ready() -> void:
	randomize()
	
func get_cell_size() -> int:
	return 32

func slow_rotate_to_point(node:Node3D, point:Vector3, rotation_speed:float, delta:float) -> void:
	const dot_threshold = .999
	var T:Transform3D

	var target_direction := (point-node.global_transform.origin).normalized()
	if abs(target_direction.dot(Vector3.UP)) < dot_threshold:
		#use Vector3.UP
		T=node.global_transform.looking_at(point, Vector3.UP)
	else: 
		#use Vector3.RIGHT
		T=node.global_transform.looking_at(point, Vector3.RIGHT)
		
	
	var sourceQ:Quaternion = Quaternion(node.global_transform.basis)
	var destQ:Quaternion = Quaternion(T.basis)
	var calc_speed:float = rotation_speed*delta
	var resultQ:Quaternion = sourceQ.slerp(destQ,calc_speed)
	node.global_transform.basis = Basis(resultQ)

func slow_rotate_to_point_flat(node:Node3D, point:Vector3, rotation_speed:float, delta:float) -> void:
	var flattened_target:Vector3 = Vector3(point.x, node.global_transform.origin.y, point.z)
	slow_rotate_to_point(node, flattened_target, rotation_speed, delta)

func random_angle_deviation_moa(node:Node3D, max_vert_moa:float, max_hor_moa:float) -> void:
	var vert_moa:float = randf_range(-max_vert_moa/2, max_vert_moa/2)
	var hor_moa:float = randf_range(-max_hor_moa/2, max_hor_moa/2)
	node.rotate_x(moa_to_rad(vert_moa))
	node.rotate_y(moa_to_rad(hor_moa))
	
func moa_to_rad(moa:float) -> float:
	return moa * 0.00029

#Only call during _physics_process
func los_to_point(target:Node3D, sources:Array[Node3D], threshold:float, exclusions:Array[RID] = []) -> bool:
	var num_sources:int = sources.size()
	var num_los:float = 0.0
	var space_state:PhysicsDirectSpaceState3D = target.get_world_3d().direct_space_state
	if space_state:
		var target_global_pos:Vector3 = target.global_position
		for source in sources:
			var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(source.global_transform.origin,\
				target_global_pos)
			if exclusions.size() > 0:
				query.exclude = exclusions
			var result:Dictionary = space_state.intersect_ray(query)
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
		list.append((node as CollisionObject3D).get_rid())
	for i in range(node.get_child_count()):
		var child:Node = node.get_child(i)
		if child.get_child_count() > 0:
			var child_cols:Array[RID] = get_all_collision_object_3d_recursive(child)
			list.append_array(child_cols)
	return list
	
## Converts dumb stupid Godot degrees into good actual real 360 degrees
func gddeg_to_compass_deg(unnormal_deg:int) -> int:
	var normal_deg:int = 0 
	if unnormal_deg < 0:
		normal_deg = -unnormal_deg
	elif unnormal_deg > 0:
		normal_deg = 360 - (unnormal_deg % 360)
	return normal_deg % 360

func get_control_in_group_with_method_at_position(cursor_pos:Vector2, group_name:String, method_name:String) -> Control:
	var containers:Array[Node] = get_tree().get_nodes_in_group(group_name)
	for c in containers:
		if c is Control and (c as Control).get_global_rect().has_point(cursor_pos):
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
	var duplicated_node:Node = original_node.duplicate()
	
	# Return the duplicated node
	return duplicated_node

func force_parent(child:Node, parent:Node) -> void:
	if child.get_parent():
		child.get_parent().remove_child(child)
	parent.add_child(child)
	if parent.owner:
		child.set_owner(parent.owner)
	else:
		child.set_owner(parent)

func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func get_aabb_of_node(node:Node) -> AABB:
	var aabb:AABB = AABB()
	if node.has_method("get_aabb") and node.visible:
		aabb = node.get_aabb()
	elif node is CollisionShape3D:
		var shape:Shape3D = (node as CollisionShape3D).shape
		var array_mesh:ArrayMesh = shape.get_debug_mesh()
		aabb = array_mesh.get_aabb()
	for child in node.get_children():
		aabb = aabb.merge(get_aabb_of_node(child))
		
	#print_verbose("returning aabb for node:" + node.name + " with aabb " + str(aabb))
	return aabb

func get_all_mesh_nodes(node:Node) -> Array[MeshInstance3D]:
	var mesh_nodes:Array[MeshInstance3D] =[]
	for N:Node in node.get_children():
		if N is MeshInstance3D:
			mesh_nodes.append(N)
		if N.get_child_count() > 0:
			mesh_nodes.append_array(get_all_mesh_nodes(N))
		else:
			# Do something
			pass
	return mesh_nodes
	
func set_material_overlay(meshes:Array[MeshInstance3D],mat:Material) -> void:
	for m in meshes:
		if m != null:
			var mesh:MeshInstance3D = m
			mesh.material_overlay = mat

func apply_material_overlay_to_children(target:Node, mat:Material) -> void:
	var meshes:Array[MeshInstance3D] = Helpers.get_all_mesh_nodes(target)
	set_material_overlay(meshes,mat)


func distance_between(source:Node3D, target:Node3D) -> float:
	var diff_vec:Vector3 = target.global_position - source.global_position
	var distance = abs(diff_vec.length())
	return distance

static var _GODOT_TO_QUAKE_FACTOR:float = 0.0254
func convert_quake_unit_to_godot_unit(qu:float) -> float:
	return qu * _GODOT_TO_QUAKE_FACTOR
	
func convert_godot_unit_to_quake_unit(gu:float) -> float:
	return gu / _GODOT_TO_QUAKE_FACTOR

func convert_quake_vector_to_godot_vector(qv:Vector3) -> Vector3:
	var gv:Vector3 = Vector3.ZERO
	gv.x = convert_quake_unit_to_godot_unit(qv.x)
	gv.y = convert_quake_unit_to_godot_unit(qv.y)
	gv.z = convert_quake_unit_to_godot_unit(qv.z)
	return gv
	
func convert_godot_vector_to_quake_vector(gv:Vector3) -> Vector3:
	var qv:Vector3 = Vector3.ZERO
	qv.x = convert_quake_unit_to_godot_unit(gv.x)
	qv.y = convert_quake_unit_to_godot_unit(gv.y)
	qv.z = convert_quake_unit_to_godot_unit(gv.z)
	return qv

##Hope there aren't collisions!
func generate_new_id() -> int:
	return randi()
