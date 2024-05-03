@tool
extends Node3D

@export var func_godot_properties: Dictionary :
	get:
		return func_godot_properties
	set(new_properties):
		if(func_godot_properties != new_properties):
			func_godot_properties = new_properties
			update_properties()

func update_properties():
	if 'target' in func_godot_properties and func_godot_properties.target != "":
		self.name = func_godot_properties.target
		self.unique_name_in_owner = true
