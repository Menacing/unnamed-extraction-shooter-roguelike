@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Set Fire Target Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		agent.set_fire_target()
		return SUCCESS
		
	return FAILURE
