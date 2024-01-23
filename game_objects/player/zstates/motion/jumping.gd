extends PlayerMotion
class_name Jumping

@export var jump_speed:float = 4.5

var input_direction:Vector2

func enter():
	super()
	input_direction = get_input_direction()
	owner.velocity.y = jump_speed
	
func update(delta):
	if owner.is_on_floor():
		emit_signal("finished", "previous")
	else:
		owner.velocity.y -= owner.gravity * delta
		owner.move_and_slide()
