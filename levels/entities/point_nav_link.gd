@tool
extends NavigationLink3D
class_name PointNavigationLink

@export var func_godot_properties: Dictionary

@export var _start_name:String
@export var _end_name:String

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'startname' in entity_properties:
		_start_name = entity_properties.startname
	if 'endname' in entity_properties:
		_end_name = entity_properties.endname

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if _start_name:
		var start_node = get_node("%"+_start_name)
		if start_node:
			set_global_start_position(start_node.global_position)
	if _end_name:
		var end_node = get_node("%"+_end_name)
		if end_node:
			set_global_end_position(end_node.global_position)
