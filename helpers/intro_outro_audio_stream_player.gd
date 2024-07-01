extends AudioStreamPlayer3D
class_name IntroOutroAudioStreamPlayer

@export var loop_start_time:float
@export var loop_end_time:float
@export var OutroStreamPlayer:AudioStreamPlayer3D

var _first_play := true

var _playback_position:float
var _stop_requested := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Setting instantiated audio stream player to SFX bus
	OutroStreamPlayer.set_bus("SFX")
	self.finished.connect(_on_finished)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		_playback_position = get_playback_position()
		
		if (_first_play and _playback_position >= loop_start_time):
			_first_play = false
			
		if !_first_play and !_stop_requested and (_playback_position >= loop_end_time or _playback_position <= loop_start_time):
			seek(loop_start_time)
	pass

func request_stop():
	_stop_requested = true


func _on_finished():
	OutroStreamPlayer.play()
	_stop_requested = false
	_first_play = true
