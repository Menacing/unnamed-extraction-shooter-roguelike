extends ConditionLeaf
class_name HasLOSConditionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.has_los_to_player():
			return SUCCESS
		
	return FAILURE
