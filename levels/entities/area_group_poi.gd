extends Area3D
class_name AreaGroupPOI

@export var func_godot_properties: Dictionary

@export var godot_group_names:Array[String]

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'godot_group_names' in func_godot_properties:
		godot_group_names = func_godot_properties['godot_group_names']

func _ready():
	for group_name_s in godot_group_names:
		add_to_group(group_name_s)
