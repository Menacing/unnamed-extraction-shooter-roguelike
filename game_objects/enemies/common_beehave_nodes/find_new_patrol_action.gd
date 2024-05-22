extends ActionLeaf
class_name FindNewPatrolTargetAction

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.find_new_patrol_poi_move_target():
			return SUCCESS
		
	return FAILURE

