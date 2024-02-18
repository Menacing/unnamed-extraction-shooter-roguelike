extends Node

var _ammo_types:Array[AmmoType]
var _path = "res://components/ammo_component/ammo_types/"

func _ready():
	var dir = DirAccess.open(_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var res = load(_path + "/" + file_name) 
				if res is AmmoType:
					_ammo_types.append(res)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func get_ammo_types() -> Array[AmmoType]:
	return _ammo_types
