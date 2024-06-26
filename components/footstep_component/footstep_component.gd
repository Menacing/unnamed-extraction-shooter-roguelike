extends Node3D
class_name FootstepComponent

@onready var audio_player = $FootstepAudioStreamPlayer3D
@onready var timer = $FoostepTimer
@onready var ray_cast:RayCast3D = $RayCast3D

@export var step_delay:float = .2
@export var default_move_speed = 1.0

@export var velocity_haver:Node3D

func _ready():
	var rids_to_exclude:Array[RID] = Helpers.get_all_collision_object_3d_recursive(velocity_haver)
	for rid:RID in rids_to_exclude:
		ray_cast.add_exception_rid(rid)

func _on_foostep_timer_timeout():
		#If moving
		if velocity_haver and velocity_haver.velocity.length() > 0:
			#If colliding
			if ray_cast.is_colliding():
				var gbs_collider := ray_cast.get_collider() as GeoBallisticSolid
				#get sound from material
				if gbs_collider and gbs_collider._footstep_sound:
					#set sound to player
					audio_player.stream = gbs_collider._footstep_sound
					#Set pitch scale
					audio_player.pitch_scale = randf_range(.9,1.1)
					#play
					audio_player.play()
					#calculate new delay
					var new_delay:float = step_delay
					var ratio = velocity_haver.velocity.length() / default_move_speed
					if ratio > 0:
						new_delay = new_delay / ratio
					#restart timer
					timer.start(new_delay)
		
	

