extends Node3D
class_name footstep_manager

@onready var audio_player = $FootstepAudioStreamPlayer3D
@onready var timer = $FoostepTimer

@export var stepper_state_machine:StateMachine
@export var step_delay:float = .2


func _physics_process(delta):
	#Check if moving
	if (stepper_state_machine and is_state_a_motion_state(stepper_state_machine.current_state)):
		#If Moving check if timer is expired
		if timer.time_left <= 0:
			#If timer is expired, play step and restart timer
			audio_player.pitch_scale = randf_range(.8,1.2)
			audio_player.play()
			timer.start(step_delay)
			
			#TODO write helper class to get sound for stepped on material
			#TODO scale the delay based on the move speed
	pass


func is_state_a_motion_state(current_state:State) -> bool:
		if (current_state is Walking or current_state is Sprinting or current_state is CrouchWalking):
			return true
		else:
			return false
