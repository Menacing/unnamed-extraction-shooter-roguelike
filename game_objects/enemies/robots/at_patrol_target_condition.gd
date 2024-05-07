extends ConditionLeaf
class_name AtPatrolTargetCondition

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var result = actor.is_in_target_patrol_poi()
	if result:
		return SUCCESS
	else:
		return FAILURE
