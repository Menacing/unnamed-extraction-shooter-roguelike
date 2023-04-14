@tool
extends ggsSetting

@export var game_setting_name:String

func _init() -> void:
	super()
	name="int_game_setting"
	value_type = TYPE_INT
	default = false


func apply(value: int) -> void:
	GameSettings.set(game_setting_name, value)
