extends Crouching
class_name CrouchWalking

@export var couch_speed:float = 2.5

func update(_delta):
	super(_delta)
	var input_direction = get_input_direction()
	if input_direction:
		move(couch_speed, input_direction, _delta)
	else:
		emit_signal("finished", "crouching")
