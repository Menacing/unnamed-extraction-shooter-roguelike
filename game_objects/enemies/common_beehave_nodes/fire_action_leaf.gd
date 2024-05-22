extends ActionLeaf
class_name FireActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		if actor.fire_weapon():
			return SUCCESS
		
	return FAILURE

