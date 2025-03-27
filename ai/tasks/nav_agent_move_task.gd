@tool
extends BTAction

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Move"

var move_target_var = "move_target"
var nav_agent_var = "nav_agent"
var move_target_distance_var = "move_target_distance"
var max_move_speed_var = "max_move_speed"
var acceleration_var = "acceleration"
var body_rotation_speed_var = "body_rotation_speed"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if blackboard.has_var(move_target_var) and blackboard.has_var(nav_agent_var) \
		and blackboard.has_var(move_target_distance_var) and blackboard.has_var(max_move_speed_var) \
		and blackboard.has_var(acceleration_var) and blackboard.has_var(body_rotation_speed_var):
		var move_target:Node3D = blackboard.get_var(move_target_var)
		var nav_agent:NavigationAgent3D = blackboard.get_var(nav_agent_var)
		var move_target_distance:float = blackboard.get_var(move_target_distance_var)
		var max_move_speed:float = blackboard.get_var(max_move_speed_var)
		var acceleration:float = blackboard.get_var(acceleration_var)
		var body_rotation_speed:float = blackboard.get_var(body_rotation_speed_var)
		
		if is_near_move_target(move_target, move_target_distance):
			#blackboard.set_var(move_target_var, scene_root)
			#agent.set_new_path()
			return SUCCESS
		move_agent(p_delta, nav_agent, max_move_speed, acceleration, body_rotation_speed)
		return RUNNING
		
	return FAILURE

func move_agent(p_delta, nav_agent:NavigationAgent3D, max_move_speed:float, acceleration:float, body_rotation_speed:float):
	if nav_agent.is_navigation_finished():
		return
	slow_body_turn(p_delta, body_rotation_speed)
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var current_velocity:Vector3 = agent.velocity
	var target_velocity:Vector3 = agent.global_position.direction_to(next_path_position) * max_move_speed
	var new_velocity = current_velocity.move_toward(target_velocity, acceleration)
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		agent._on_velocity_computed(new_velocity)
		
func slow_body_turn(delta:float, body_rotation_speed:float):
	if agent.velocity.length() > 0.01:
		var target_direction = agent.velocity.normalized()
		var forward = Vector3(target_direction.x, 0, target_direction.z).normalized()  # Ignore Y component

		if forward.length() > 0:
			var current_basis = agent.global_transform.basis.orthonormalized()
			var target_basis = Basis().looking_at(forward, Vector3.UP, true).orthonormalized()

			# Smooth interpolation
			agent.global_transform.basis = current_basis.slerp(target_basis, delta * body_rotation_speed)  # Adjust speed


func is_near_move_target(move_target:Node3D, move_target_distance:float):
	if move_target is Area3D:
		return move_target.overlaps_body(scene_root)
	else:
		var dis = Helpers.distance_between(scene_root, move_target)
		if dis <= move_target_distance:
			return true
	
	return false
