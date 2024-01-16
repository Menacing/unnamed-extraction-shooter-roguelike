extends StateMachine
class_name PlayerMotionStateMachine
@onready var standing = $Standing
@onready var walking = $Walking
@onready var crouching = $Crouching
@onready var crouch_walking = $CrouchWalking
@onready var sprinting = $Sprinting
@onready var jumping = $Jumping
@onready var prone = $Prone

@onready var parent_id:int = get_parent().get_instance_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	states_map = {
		"sprinting": sprinting,
		"jumping": jumping,
		"standing": standing,
		"walking": walking,
		"crouching": crouching,
		"crouch_walking": crouch_walking,
		"prone": prone,
	}
	EventBus.location_destroyed.connect(_on_location_destroyed)
	EventBus.location_restored.connect(_on_location_restored)


func _change_state(state_name):
	# The base state_machine interface this node extends does most of the work.
	if not _active:
		return
	if state_name in ["jumping"]:
		states_stack.push_front(states_map[state_name])
#	if state_name == "jump" and current_state == move:
#		jump.initialize(move.speed, move.velocity)
	if OS.is_debug_build():
		pass
#		print("Player State: %s" % state_name)
	super._change_state(state_name)


func _unhandled_input(event):
	# Here we only handle input that can interrupt states, attacking in this case,
	# otherwise we let the state node handle it.
#	if event.is_action_pressed("attack"):
#		if current_state in [attack, stagger]:
#			return
#		_change_state("attack")
#		return
	current_state.handle_input(event)
	
func _on_location_destroyed(actor_id:int, location:HealthLocation.HEALTH_LOCATION):
	if actor_id == parent_id:
		if location == HealthLocation.HEALTH_LOCATION.LEGS:
			owner.legs_destroyed = true
			emit_signal("finished", "prone")

func _on_location_restored(actor_id:int, location:HealthLocation.HEALTH_LOCATION):
	if actor_id == parent_id:
		if location == HealthLocation.HEALTH_LOCATION.LEGS:
			owner.legs_destroyed = false
