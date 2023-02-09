extends PlayerMotion
class_name OnGround

# warning-ignore-all:unused_class_variable
var toggle_sprint: bool = false
var toggle_crouch: bool = false
var accel:float = 1.0

func handle_input(event):
	if event.is_action_pressed("jump"):
		emit_signal("finished", "standing")
	return super.handle_input(event)

func enter():
	super()
	toggle_sprint = owner.toggle_sprint
	toggle_crouch = owner.toggle_crouch
	accel = owner.accel

func should_sprint() -> bool:
	if toggle_sprint:
		if Input.is_action_just_pressed("sprint"):
			owner.toggle_sprint_f = !owner.toggle_sprint_f
		return owner.toggle_sprint_f
	else:
		return Input.is_action_pressed("sprint")
		
func should_crouch() -> bool:
	if toggle_crouch:
		if Input.is_action_just_pressed("crouch"):
			owner.toggle_crouch_f = !owner.toggle_crouch_f
		return owner.toggle_crouch_f
	else:
		return Input.is_action_pressed("crouch")
		
func should_prone() -> bool:
	if Input.is_action_just_pressed("prone"):
		owner.toggle_prone_f = !owner.toggle_prone_f
	return owner.toggle_prone_f

func move(speed, input_dir, delta):
	if not owner.is_on_floor():
		owner.velocity.y -= owner.gravity * delta
	var direction:Vector3 = (owner.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		owner.velocity.x = direction.x * speed
		owner.velocity.z = direction.z * speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, accel)
		owner.velocity.z = move_toward(owner.velocity.z, 0, accel)

	owner.move_and_slide()
