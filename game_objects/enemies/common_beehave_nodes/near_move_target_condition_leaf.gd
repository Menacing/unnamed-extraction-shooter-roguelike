extends ConditionLeaf
class_name NearMoveTargetCondition

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.is_near_move_target():
			return SUCCESS
		
	return FAILURE
