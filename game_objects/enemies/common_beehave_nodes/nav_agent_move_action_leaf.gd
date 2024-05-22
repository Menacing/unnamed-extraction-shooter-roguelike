extends ActionLeaf
class_name NavAgentMoveActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		actor.nav_agent_move()
		return SUCCESS
		
	return FAILURE
