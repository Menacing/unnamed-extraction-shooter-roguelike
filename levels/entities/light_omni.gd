@tool
class_name LightOmni
extends OmniLight3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	omni_range = Helpers.convert_quake_unit_to_godot_unit((props["range"] as float))
