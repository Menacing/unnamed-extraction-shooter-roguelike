@tool
extends BTAction
## SlowWeaponTurnTask

# Display a customized name (requires @tool).
func _generate_name():
	return "Attack Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent.gun_node:
			Helpers.random_angle_deviation_moa(agent.gun_node,agent.vert_moa,agent.hor_moa)
			agent.gun_node.fireGun()
			return SUCCESS
	return FAILURE
