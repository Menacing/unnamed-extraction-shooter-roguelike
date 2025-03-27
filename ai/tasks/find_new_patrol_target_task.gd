@tool
extends BTAction

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Find New Patrol Target"

var move_target_var = "move_target"

# Called each time this task is ticked (aka executed).
func _tick(p_delta: float) -> Status:
	var pois = scene_root.get_tree().get_nodes_in_group("PatrolPOI")
	pois.shuffle()
	
	for poi in pois:
		#if POI is not an Area3D, skip
		if not poi is Area3D:
			break
		#If we don't currently have a target, take the first one
		if !blackboard.has_var(move_target_var):
			blackboard.set_var(move_target_var, poi)
			return SUCCESS
		#If the current target is the poi, skip it
		if poi == blackboard.get_var(move_target_var):
			break
		else:
			blackboard.set_var(move_target_var, poi)
			return SUCCESS
		#else take the poi
	return FAILURE
		
