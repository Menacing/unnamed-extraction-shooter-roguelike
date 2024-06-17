@tool
class_name LightSpot
extends SpotLight3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	spot_angle = props["spot_angle"] as float
	spot_range = Helpers.convert_quake_unit_to_godot_unit((props["range"] as float))
