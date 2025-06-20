@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Slow Agent Turn Task"
	
# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent._attack_target and agent.body_rotation_speed:
			Helpers.slow_rotate_to_point(agent, agent._attack_target.global_transform.origin, agent.body_rotation_speed.get_modified_value(), delta, true)
			return SUCCESS

	return FAILURE
