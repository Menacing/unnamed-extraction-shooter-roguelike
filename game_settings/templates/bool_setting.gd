@tool
extends ggsSetting

func _init() -> void:
	value_type = TYPE_BOOL
	default = false

func apply(value: bool) -> void:
	GameSettings.set(name, value)
