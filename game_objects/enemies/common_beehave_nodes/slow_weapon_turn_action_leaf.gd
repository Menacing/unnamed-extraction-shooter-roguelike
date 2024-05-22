extends ActionLeaf
class_name SlowWeaponTurnActionLeaf

func tick(actor, blackboard):
	if actor is Enemy:
		actor.slow_weapon_turn()
		return SUCCESS
		
	return FAILURE
