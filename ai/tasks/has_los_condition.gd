@tool
extends BTCondition
## NewTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Has LOS to Target Player"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent.has_los_to_player():
			return SUCCESS
		
	return FAILURE
