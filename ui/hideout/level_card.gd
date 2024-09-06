extends Control
class_name LevelCard

var level_information:LevelInformation
var original_z:int
var mouse_over_z:int = 25
var _is_selected:bool = false
signal selected(card:LevelCard)

@export var mouse_over_sound:AudioStream
@export var click_sound:AudioStream

@onready var title_label:Label = %TitleLabel
@onready var preview_rect:TextureRect = %PreviewTextureRect
@onready var biome_label:Label = %BiomeLabel
@onready var size_label:Label = %SizeLabel
@onready var desc_label:Label = %DescriptionLabel
@onready var selection_texture:Control = %SelectionTexture
@onready var mouse_over_audio_player:AudioStreamPlayer = %MouseOverAudioStreamPlayer
@onready var click_audio_player:AudioStreamPlayer = %ClickAudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if level_information:
		title_label.text = level_information.display_name
		preview_rect.texture = level_information.preview_image
		biome_label.text = LevelInformation.get_biome_string(level_information.biome)
		size_label.text = LevelInformation.get_size_string(level_information.size)
		desc_label.text = level_information.description
		pass # Replace with function body.

	mouse_over_audio_player.stream = mouse_over_sound
	click_audio_player.stream = click_sound
	original_z = z_index

var tween_hover:Tween
func _on_mouse_entered():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	mouse_over_audio_player.play()
	z_index = mouse_over_z

func _on_mouse_exited():
	#reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	mouse_over_audio_player.play()
	z_index = original_z
	
func select():
	_is_selected = true
	selection_texture.visible = true
	selected.emit(self)
	
func deselect():
	_is_selected = false
	selection_texture.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		click_audio_player.play()
		if _is_selected:
			deselect()
		else:
			select()
