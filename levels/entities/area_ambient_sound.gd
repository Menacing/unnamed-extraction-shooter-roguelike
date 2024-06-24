@tool
extends Area3D
class_name AreaAmbientSound

@export var audio_stream_path:String
@export var audio_stream:AudioStream
@export var volume_db:float = 0.0
@export var transition_duration:float = 3.0
@export var fg_reverb_bus_name:String

static var current_ambience:AreaAmbientSound = null

var player
var min_volume:float = -50.0
var tween:Tween

@export var func_godot_properties: Dictionary
func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'audio_stream_path' in func_godot_properties:
		audio_stream_path = func_godot_properties['audio_stream_path']
		audio_stream = load(audio_stream_path)
	if 'volume_db' in func_godot_properties:
		volume_db = float(func_godot_properties['volume_db'])
	if 'transition_duration' in func_godot_properties:
		transition_duration = float(func_godot_properties['transition_duration'])
	if 'fg_reverb_bus_name' in func_godot_properties:
		fg_reverb_bus_name = func_godot_properties['fg_reverb_bus_name']
		reverb_bus_enabled = true
		reverb_bus_name = fg_reverb_bus_name

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node3D) -> void:
	if body is Player and audio_stream != null:
		play()

func play() -> void:
	if audio_stream == null or current_ambience == self:
		return
	
	if player == null:
		_create_player()
	
	player.stream = audio_stream
	player.play()
	
	if current_ambience != null:
		current_ambience.stop()
	
	current_ambience = self
	
	_tween_audio(volume_db, Tween.EASE_OUT)
		
func _create_player() -> void:
	player = AudioStreamPlayer.new()
	player.name = "AmbiencePlayer"
	player.volume_db = min_volume
	var root = get_tree().root
	root.add_child(player)
	player.set_owner(root)
	
func _tween_audio(target_db:float, easing: Tween.EaseType) -> Tween:
	if tween != null:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(player, "volume_db", target_db, transition_duration).set_ease(easing).set_trans(tween.TRANS_EXPO)
	return tween
	
func stop() -> void:
	await _tween_audio(min_volume, Tween.EASE_IN).finished
	player.stop()
