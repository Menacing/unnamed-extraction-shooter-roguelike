@tool
extends ggsSetting

@export var game_setting_name:String

func _init() -> void:
	super()
	name="bool_game_setting"
	value_type = TYPE_BOOL
	default = false


func apply(value: bool) -> void:
	GameSettings.set(game_setting_name, value)
