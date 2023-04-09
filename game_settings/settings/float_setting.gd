@tool
extends ggsSetting

@export var game_setting_name:String

func _init() -> void:
	super()
	name="float_game_setting"
	value_type = TYPE_FLOAT
	default = false


func apply(value: float) -> void:
	GameSettings.set(game_setting_name, value)
