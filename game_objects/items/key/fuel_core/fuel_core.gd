extends Item3D

@onready var audio_player = $AudioStreamPlayer3D

func _ready() -> void:
	super()
	audio_player.play()

func dropped() -> void:
	super()
	audio_player.play()
	
	

func picked_up(actor_id:int = 0) -> void:
	super()
	audio_player.stop()
