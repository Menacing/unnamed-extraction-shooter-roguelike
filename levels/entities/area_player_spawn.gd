@tool
extends Area3D
class_name AreaPlayerSpawn

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	add_to_group("PlayerSpawn", true)
	
func _ready():
	add_to_group("PlayerSpawn", true)
