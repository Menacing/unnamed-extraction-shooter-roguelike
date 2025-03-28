@tool
extends BTAction


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Repath"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if agent is Enemy:
		if agent._move_target and agent.nav_agent:
			var move_target_global_position:Vector3 = agent._move_target.global_position
			agent.nav_agent.set_target_position(move_target_global_position)
			
			return SUCCESS
		
	return FAILURE
