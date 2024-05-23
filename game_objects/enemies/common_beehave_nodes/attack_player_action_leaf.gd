extends ActionLeaf
class_name AttackPlayerActionLeaf

func tick(actor, blackboard):
	if actor is Enemy and actor.target_player:
		
		actor.move_target = actor.target_player
		actor.set_new_path()
		
		actor.fire_target = actor.target_player.center_mass
		return SUCCESS
		
	return FAILURE
