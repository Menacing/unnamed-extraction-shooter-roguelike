extends ActionLeaf
class_name NavAgentMoveActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.is_near_move_target():
			return SUCCESS
		actor.nav_agent_move()
		return RUNNING
		
	return FAILURE
