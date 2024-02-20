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
		
	print_debug("returning aabb for node:" + node.name + " with aabb " + str(aabb))
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

func shapecast_step_move(cb3d:CharacterBody3D, delta:float, step_slice_height:float, max_step_height:float):
	#Shapecast in direction
	var desired_dir:Vector3 = cb3d.velocity * delta
	if is_zero_approx(desired_dir.length()):
		return
	var default_direction_test_motion_result := PhysicsTestMotionResult3D.new()
	var default_direction_test_motion_params := PhysicsTestMotionParameters3D.new()
	default_direction_test_motion_params.from = cb3d.global_transform
	default_direction_test_motion_params.motion = desired_dir
	var default_motion_collides = PhysicsServer3D.body_test_motion(cb3d.get_rid(), default_direction_test_motion_params, default_direction_test_motion_result)
	#If not collision just move and slide
	if !default_motion_collides:
		cb3d.move_and_slide()
		return
	#else begin step loop
	var has_headroom:bool = true
	if step_slice_height <= 0 or max_step_height <= 0:
		push_error("step slice height and max step height must be positive")
		return
	var test_height = step_slice_height
	#while shapecast up doesn't collide and we haven't gone past the step limit
	while(has_headroom and test_height < max_step_height):
		var headroom_test_motion_result := PhysicsTestMotionResult3D.new()
		var headroom_test_motion_params := PhysicsTestMotionParameters3D.new()
		headroom_test_motion_params.from = cb3d.global_transform
		headroom_test_motion_params.motion =  Vector3(0,test_height,0)
		#shapecast up
		var headroom_collides = PhysicsServer3D.body_test_motion(cb3d.get_rid(), headroom_test_motion_params, headroom_test_motion_result)
		var actual_vertical_travel:Vector3
		var direction_test_motion_result := PhysicsTestMotionResult3D.new()
		var direction_test_motion_params := PhysicsTestMotionParameters3D.new()
		direction_test_motion_params.from = cb3d.global_transform
		direction_test_motion_params.motion = desired_dir
		direction_test_motion_params.max_collisions = 10
		#if we hit something, only move as far as allowed and move in direction from there
		if headroom_collides:
			has_headroom = false
			actual_vertical_travel = direction_test_motion_result.get_travel()
		else:
			actual_vertical_travel = headroom_test_motion_params.motion
			
		direction_test_motion_params.from.origin += actual_vertical_travel
		
		#shapecast in direction
		var direction_motion_collides = PhysicsServer3D.body_test_motion(cb3d.get_rid(), direction_test_motion_params, direction_test_motion_result)
		
		#if no collision move
		if !direction_motion_collides:
			#move to target pos
			#first move up
			scaled_move_and_slide_vertically(cb3d, actual_vertical_travel.y,delta)
			return
		else:
			#Just increment this before doing the rest of the tests because we're just going to break if we find a solution at this height
			test_height += step_slice_height
			#Do slide move, then test down for a different floor or we'll climb walls
			var direction_movement_normal = direction_test_motion_result.get_collision_normal()
			var direction_movement_remainder = direction_test_motion_result.get_remainder()
			var direction_movement_location = direction_test_motion_result.get_collision_point()
			var direction_movement_travel = direction_test_motion_result.get_travel()
			var direction_slide_test_motion_result := PhysicsTestMotionResult3D.new()
			var direction_slide_test_motion_params := PhysicsTestMotionParameters3D.new()
			direction_slide_test_motion_params.from = direction_test_motion_params.from
			direction_slide_test_motion_params.from.origin += direction_movement_travel
			var slide_movement = direction_movement_remainder.slide(direction_movement_normal)
			direction_slide_test_motion_params.motion = slide_movement
			
			var direction_slide_collides = PhysicsServer3D.body_test_motion(cb3d.get_rid(), direction_slide_test_motion_params, direction_slide_test_motion_result)
			
			#if we hit something while sliding, we can't move at this height
			#else check down for a different height from where we started
			if !direction_slide_collides:
				var direction_slide_down_test_motion_result := PhysicsTestMotionResult3D.new()
				var direction_slide_down_test_motion_params := PhysicsTestMotionParameters3D.new()
				direction_slide_down_test_motion_params.from = direction_slide_test_motion_params.from
				direction_slide_down_test_motion_params.from.origin += direction_slide_test_motion_params.motion
				direction_slide_down_test_motion_params.motion = -actual_vertical_travel
				direction_slide_down_test_motion_params.margin = 0.0
				
				var direction_slide_down_collides = PhysicsServer3D.body_test_motion(cb3d.get_rid(), direction_slide_down_test_motion_params, direction_slide_down_test_motion_result)
				
				#if down collides at a different height than where we started, do this move
				if direction_slide_down_collides:
					var direction_slide_down_normal = direction_slide_down_test_motion_result.get_collision_normal()
					var direction_slide_down_remainder = direction_slide_down_test_motion_result.get_remainder()
					var direction_slide_down_location = direction_slide_down_test_motion_result.get_collision_point()
					var direction_slide_down_travel = direction_slide_down_test_motion_result.get_travel()
					var normal_to_up = direction_slide_down_normal.angle_to(Vector3.UP)
					var max_slope = cb3d.floor_max_angle
					
					if !is_equal_approx(direction_slide_down_travel.y, -actual_vertical_travel.y) and normal_to_up < max_slope:
						scaled_move_and_slide_vertically(cb3d, actual_vertical_travel.y,delta)
						return
				#else do nothign so we don't climb walls
	#if we never find a step, just move and slide so we don't stick to walls
	cb3d.move_and_slide()
	pass

func scaled_move_and_slide_vertically(cb3d:CharacterBody3D, vertical_travel:float, delta:float):
	var character_velocity:Vector3 = cb3d.velocity
	var vert_velocity:float = vertical_travel / delta

	var desired_magnitude = character_velocity.length() - abs(vert_velocity)
	var actual_vertical_travel:Vector3 = Vector3(0,vertical_travel,0)
	var v_col = cb3d.move_and_collide(actual_vertical_travel)
	if v_col:
		push_error("something happened, we shouldn't be hitting something after testing")
	else:
		#then move in direction
		#does just moving and sliding now just work since we moved them up?
		if desired_magnitude > 0:
			var character_velocity_direction = character_velocity.normalized()
			var scaled_velocity = character_velocity_direction * desired_magnitude
			cb3d.velocity = scaled_velocity
			cb3d.move_and_slide()
