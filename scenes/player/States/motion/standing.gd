extends OnGround
class_name Standing


func enter():
	super()
	#owner.get_node(^"AnimationPlayer").play("idle")
	collider.get_shape().set_height(2)

func handle_input(event):
	return super.handle_input(event)


func update(_delta):
	super(_delta)
	if Input.is_action_just_pressed("jump"):
		owner.toggle_sprint_f = false
		owner.toggle_crouch_f = false
		owner.toggle_prone_f = false
		emit_signal("finished","jumping")
	else:
		var input_direction = get_input_direction()
		if should_crouch():
			emit_signal("finished", "crouching")
		elif should_prone():
			emit_signal("finished", "prone")			
		elif input_direction:
			if should_sprint():
				emit_signal("finished", "sprinting")			
			else:	
				emit_signal("finished", "walking")
		else:
			move(0.0,Vector3.ZERO,_delta)
