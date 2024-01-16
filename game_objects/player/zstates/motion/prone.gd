extends OnGround
class_name Prone

@export var time_to_transition_to:float = 1
@export var time_to_transition_from:float = 0.5
@export var crawling_speed:float = 1.0
var in_timer:Timer
var out_timer:Timer
var transition_complete:bool = false
var shape:CapsuleShape3D


func _ready():
	in_timer = Timer.new()
	in_timer.wait_time = time_to_transition_to
	in_timer.one_shot = true
	in_timer.connect("timeout",in_timer_done)
	add_child(in_timer)

func in_timer_done():
	transition_complete = true

func enter():
	super()
	shape = collider.get_shape()	
	transition_complete = false
	in_timer.start()
	var tween:Tween = get_tree().create_tween()
	var tween_created = tween.tween_property(shape,"height",0.5,time_to_transition_to)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	#owner.get_node(^"AnimationPlayer").play("idle")


func update(_delta):
	if transition_complete:
		super(_delta)
		var input_direction = get_input_direction()
		if not should_prone():
			leave_prone()
		elif input_direction:
			move(crawling_speed, input_direction,_delta)
		else:
			move(0.0,Vector3.ZERO,_delta)
	else:
		move(0.0,Vector3.ZERO,_delta)

func leave_prone():
	transition_complete = false
	var tween:Tween = get_tree().create_tween()
	var tween_created = tween.tween_property(shape,"height",1,time_to_transition_from)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	out_timer = Timer.new()
	out_timer.one_shot = true
	out_timer.wait_time = time_to_transition_from
	out_timer.connect("timeout",out_timer_done)
	add_child(out_timer)
	out_timer.start()	

func out_timer_done():
	emit_signal("finished", "crouching")
