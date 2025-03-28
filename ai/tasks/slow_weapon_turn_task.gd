@tool
extends BTAction
## SlowWeaponTurnTask


# Display a customized name (requires @tool).
func _generate_name():
	return "Slow Weapon Turn Task"
	
# Called each time this task is ticked (aka executed).
func _tick(delta) -> Status:
	if agent is Enemy:
		if agent._attack_target and agent.weapon_rotation_speed:
			
			#if not agent. and blackboard.has_var(head_node_var):
				#var head_node:Node3D = blackboard.get_var(head_node_var)
				#Helpers.slow_rotate_to_point(head_node, attack_target.global_transform.origin, weapon_rotation_speed, delta)
				#return SUCCESS
			if agent.gun_node:
				Helpers.slow_rotate_to_point(agent.gun_node, agent._attack_target.global_transform.origin, agent.weapon_rotation_speed, delta)
				return SUCCESS

	return FAILURE
