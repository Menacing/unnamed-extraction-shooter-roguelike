@tool
extends BTAction
## ForgetPlayerTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Forget Player Task"


# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		agent.target_player = null
		agent.fire_target = null
		return SUCCESS
		
	return FAILURE

