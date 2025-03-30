@tool
extends BTAction


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Repath"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if agent is Enemy and agent.nav_agent:
		if agent._move_target:
			agent._move_target_gpos = agent._move_target.global_position
			agent.nav_agent.set_target_position(agent._move_target_gpos)
			
			return SUCCESS
		elif agent._move_target_gpos:
			agent.nav_agent.set_target_position(agent._move_target_gpos)
			
			return SUCCESS
	return FAILURE
