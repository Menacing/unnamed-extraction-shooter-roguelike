@tool
extends BTAction

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Move"


# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if agent is Enemy:
		if agent.is_near_move_target():
			agent.move_target = agent
			agent.set_new_path()
			return SUCCESS
		agent.slow_body_turn(p_delta)
		return RUNNING
		
	return FAILURE
