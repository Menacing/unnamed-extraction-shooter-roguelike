extends ActionLeaf
class_name RepathActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		actor.set_new_path()
		return SUCCESS
		
	return FAILURE
