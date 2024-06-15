@tool
extends Node3D

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'target' in func_godot_properties and func_godot_properties.target != "":
		self.name = func_godot_properties.target
		self.unique_name_in_owner = true
