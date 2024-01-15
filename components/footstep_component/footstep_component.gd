extends Node3D
class_name footstep_manager

@onready var audio_player = $FootstepAudioStreamPlayer3D
@onready var timer = $FoostepTimer

@export var step_delay:float = .2

func _physics_process(delta):
	#Check if moving
	#TODO Fix this
	#If Moving check if timer is expired
	if timer.time_left <= 0:
		#If timer is expired, play step and restart timer
		audio_player.pitch_scale = randf_range(.8,1.2)
		audio_player.play()
		timer.start(step_delay)
		
		#TODO write helper class to get sound for stepped on material
		#TODO scale the delay based on the move speed

