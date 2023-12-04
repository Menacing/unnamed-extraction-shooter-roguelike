extends Resource
class_name AmmoSubtype

func _init():
	resource_local_to_scene = true

@export var name:String
@export var abbreviation:String
@export var maximum_capacity:int
var current_amount:int = 0 
