extends ActionLeaf
class_name NavAgentMoveActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.is_near_move_target():
			actor.move_target = actor
			actor.set_new_path()
			return SUCCESS
		return RUNNING
		
	return FAILURE
