extends ConditionLeaf
class_name HasPatrolTargetCondition

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.target_patrol_poi:
		return SUCCESS
	else:
		return FAILURE
