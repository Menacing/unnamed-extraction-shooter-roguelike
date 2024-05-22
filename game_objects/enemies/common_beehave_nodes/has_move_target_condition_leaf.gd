extends ConditionLeaf
class_name HasMoveTargetCondition

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.has_move_target():
			return SUCCESS
		
	return FAILURE
