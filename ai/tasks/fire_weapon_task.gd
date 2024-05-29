@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Fire Weapon Task"

# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		agent.fire_weapon()
		return SUCCESS
		
	return FAILURE
