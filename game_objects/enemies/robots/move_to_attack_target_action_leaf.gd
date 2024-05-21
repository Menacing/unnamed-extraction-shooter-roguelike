extends ActionLeaf
class_name MoveToAttackTargetActionLeaf

func tick(actor, blackboard):
	
	if actor.is_in_target_patrol_poi():
		return SUCCESS
		
	actor.set_movement_target(actor.target_patrol_poi.global_position)

	return RUNNING
