extends ConditionLeaf
class_name HasFireTargetCondition

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.has_fire_target():
			return SUCCESS
		
	return FAILURE
