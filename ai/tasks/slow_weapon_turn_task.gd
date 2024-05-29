@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Slow Weapon Turn Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		agent.slow_weapon_turn()
		return SUCCESS
		
	return FAILURE
