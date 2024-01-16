extends Standing
class_name Sprinting

@export var sprint_speed: float = 10.0

func update(_delta):
	super(_delta)
	var input_direction = get_input_direction()
	if is_equal_approx(input_direction.length(), 0.0):
		emit_signal("finished", "standing")
	elif not should_sprint():
		emit_signal("finished", "walking")
	else:
		move(sprint_speed, input_direction, _delta)
