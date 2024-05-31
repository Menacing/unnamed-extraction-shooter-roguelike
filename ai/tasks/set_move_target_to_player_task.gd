@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Set Move Target To Player Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent.target_player:
			agent.move_target = agent.target_player
			return SUCCESS
		
	return FAILURE
