@tool
extends Area3D
class_name AreaAIDoorOpener

@export var door:GeoBallisticDoor
@export var _target:String

@export var func_godot_properties: Dictionary
func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'target' in func_godot_properties:
		_target = func_godot_properties.target

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if !Engine.is_editor_hint() and _target:
		var door_node = get_node("%"+_target)
		if door_node:
			door = door_node

func _on_body_entered(body:Node3D) -> void:
	if body is Enemy and door:
		door.open_door()
		pass
	pass
		
func _on_body_exited(body:Node3D) -> void:
	if body is not Player:
		var bodies = get_overlapping_bodies()
		
		for ebody in bodies:
			if ebody is Enemy:
				#Enemy still in area
				return
		
		#No enemies remain in area
		if door:
			door.close_door()
		pass
