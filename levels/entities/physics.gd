@tool
class_name PhysicsEntity
extends RigidBody3D

@export var func_godot_properties: Dictionary :
	get:
		return func_godot_properties
	set(new_properties):
		if(func_godot_properties != new_properties):
			func_godot_properties = new_properties
			update_properties()

func update_properties():
	if 'velocity' in func_godot_properties:
		linear_velocity = func_godot_properties['velocity']

	if 'mass' in func_godot_properties:
		mass = func_godot_properties.mass


func use():
	bounce()

func bounce():
	linear_velocity.y = 10
