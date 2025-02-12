@tool
extends BTAction
## AttackTargetInRangeTask


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Attack Target In Range Task"




# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent is Enemy:
		if agent.attack_target_in_range():
			return SUCCESS
		
	return FAILURE
