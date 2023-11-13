@tool
extends ggsSetting

func _init() -> void:
	value_type = TYPE_FLOAT
	default = false


func apply(value: float) -> void:
	GameSettings.set(name, value)
