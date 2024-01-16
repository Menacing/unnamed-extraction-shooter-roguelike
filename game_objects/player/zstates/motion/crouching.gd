extends OnGround
class_name Crouching

func enter():
	super()
	#owner.get_node(^"AnimationPlayer").play("idle")
	collider.get_shape().set_height(1)
	

func handle_input(event):
	return super.handle_input(event)


func update(_delta):
	super(_delta)
	var input_direction = get_input_direction()
	if not should_crouch():
		emit_signal("finished", "standing")
	elif input_direction:
		emit_signal("finished", "crouch_walking")
	else:
		move(0.0,Vector3.ZERO, _delta)
