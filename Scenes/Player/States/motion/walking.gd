extends Standing
class_name Walking

@export var walk_speed:float = 5.0

func update(_delta):
	super(_delta)
	var input_direction = get_input_direction()
	if is_equal_approx(input_direction.length(), 0.0):
		emit_signal("finished", "standing")

	if should_sprint():
		emit_signal("finished", "sprinting")
	else:
		move(walk_speed, input_direction, _delta)
