extends ActionLeaf
##Runs forever. Be sure to use a time limiter decorator
class_name LoiterActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		#TODO Trigger an idle animation or something
		return RUNNING
		
	return FAILURE
