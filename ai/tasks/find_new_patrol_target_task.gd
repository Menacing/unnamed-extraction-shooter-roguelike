@tool
extends BTAction

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Find New Patrol Target"


# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	if agent is Enemy:
		if agent.find_new_patrol_poi_move_target():
			return SUCCESS
		
	return FAILURE
