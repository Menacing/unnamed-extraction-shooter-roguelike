@tool
extends Node3D

@export var func_godot_properties: Dictionary
@export var _target:String 
@export var _door_node:GeoBallisticDoor 

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'target' in func_godot_properties and func_godot_properties.target != "":
		_target = func_godot_properties.target
		#self.name = func_godot_properties.target
		#self.unique_name_in_owner = true


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if _target:
		var door_node = get_node("%"+_target)
		if door_node and door_node is GeoBallisticDoor:
			_door_node = door_node
			call_deferred("reparent_hinge")


func reparent_hinge():
	#calculate new offset for door
	var new_door_offset = _door_node.global_transform.origin - self.global_transform.origin
	#reparent
	Helpers.force_parent(_door_node, self)
	#set new door transform
	_door_node.transform.origin = new_door_offset
	#set target values
	_door_node.base_transform = self.transform
	_door_node.target_transform = _door_node.base_transform
	_door_node._hinge = self
