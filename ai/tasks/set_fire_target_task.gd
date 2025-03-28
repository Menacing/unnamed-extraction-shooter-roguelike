@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Set Attack Target Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		agent.find_best_visible_enemy()
		blackboard.set_var("_attack_target", agent._attack_target)
		return SUCCESS
		
	return FAILURE
