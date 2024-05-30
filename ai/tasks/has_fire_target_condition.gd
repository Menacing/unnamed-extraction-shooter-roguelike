@tool
extends BTCondition
## NewTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Has Fire Target"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent.has_fire_target():
			return SUCCESS
		
	return FAILURE
