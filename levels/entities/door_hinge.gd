@tool
extends Node3D

@export var properties: Dictionary :
	get:
		return properties
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

func update_properties():
	if 'target' in properties and properties.target != "":
		self.name = properties.target
		self.unique_name_in_owner = true
