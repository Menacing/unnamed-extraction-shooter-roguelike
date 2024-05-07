extends ActionLeaf
class_name FindNewPatrolTargetAction

func tick(actor, blackboard):
	var result = actor.find_new_target_patrol_poi()
	if result:
		return SUCCESS
	else:
		return FAILURE
