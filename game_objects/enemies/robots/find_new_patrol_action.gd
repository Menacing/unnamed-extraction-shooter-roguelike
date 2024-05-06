extends ActionLeaf
class_name FindNewPatrolTargetAction

func tick(actor, blackboard):
	
	#if !blackboard.has_value("target_building"):
		#return FAILURE
	#if !actor.in_range(blackboard.get_value("target_building").position):
		#return FAILURE
	#actor.enter_building(blackboard.get_value("target_building"))
	#blackboard.erase_value("target_building")
	return SUCCESS
