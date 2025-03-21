extends Control

@export var visibility_setting:ggsSetting 

func _ready() -> void:
	self.visible = GGS.get_value(visibility_setting)
	GGS.setting_applied.connect(_setting_applied)

func _setting_applied(setting: String, value: Variant):
	if setting =="downsampling_enabled":
		self.visible = value
