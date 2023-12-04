extends Resource
class_name AmmoType

func _init():
	resource_local_to_scene = true

@export var name:String
@export var sub_types:Array[AmmoSubtype]
