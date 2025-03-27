@tool
extends BTAction


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Nav Agent Repath"
	
var move_target_var = "move_target"
var nav_agent_var = "nav_agent"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:

	
	if blackboard.has_var(move_target_var) and blackboard.has_var(nav_agent_var):
		var move_target:Node3D = blackboard.get_var(move_target_var)
		var nav_agent = blackboard.get_var(nav_agent_var)
		var move_target_global_position := move_target.global_position
		nav_agent.set_target_position(move_target_global_position)
		
		return SUCCESS
		
	return FAILURE
