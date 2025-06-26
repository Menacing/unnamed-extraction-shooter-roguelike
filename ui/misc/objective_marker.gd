extends MarginContainer
class_name ObjectiveMarker

@onready var down_indicator: TextureRect = %DownIndicator
@onready var up_indicator: TextureRect = %UpIndicator
@onready var label: Label = %Label
var _label_text:String

var vertical_margin:float = 3.0

func _ready() -> void:
	label.text = _label_text

func set_label(new_text:String):
	if label:
		label.text = new_text
	
	_label_text = new_text

func calculate_verticallity(player_pos:Vector3, objective_pos:Vector3):
	var vertical_distance = (player_pos - objective_pos).y
	
	if vertical_distance >= vertical_margin:
		up_indicator.visible = false
		down_indicator.visible = true
	elif vertical_distance <= -vertical_margin:
		down_indicator.visible = false
		up_indicator.visible = true
	else:
		down_indicator.visible = false
		up_indicator.visible = false
	pass
