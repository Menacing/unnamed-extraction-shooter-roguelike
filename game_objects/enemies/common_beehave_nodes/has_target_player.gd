extends ConditionLeaf
class_name HasTargetPlayerConditionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.has_target_player():
			return SUCCESS
		
	return FAILURE
