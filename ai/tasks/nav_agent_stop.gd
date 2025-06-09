@tool
extends BTAction


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Stop"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if agent is Enemy:
		if agent.nav_agent:
			if !agent.nav_agent.is_navigation_finished():
				agent.nav_agent.target_position = agent.global_position
			
			if agent.nav_agent.velocity != Vector3.ZERO:
				agent.nav_agent.velocity = Vector3.ZERO
				
			if agent.velocity.length() > 0.001:  # Stop once it's very close to zero
				agent.velocity = agent.velocity.move_toward(Vector3.ZERO, agent.acceleration.get_modified_value())
				return RUNNING
			else:
				agent.velocity = Vector3.ZERO  # Prevent tiny values from lingering
				return SUCCESS

	return FAILURE
