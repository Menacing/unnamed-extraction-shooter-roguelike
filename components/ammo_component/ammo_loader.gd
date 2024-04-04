extends Node

var _ammo_types:Array[AmmoType]
var _path = "res://components/ammo_component/ammo_types/"

func _ready():
	load_ammo_info_from_path(_path)

func load_ammo_info_from_path(path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				load_ammo_info_from_path(path + "/" + file_name)
			else:
				if file_name.ends_with(".tres"):
					var res = load(path + "/" + file_name) 
					if res is AmmoType:
						_ammo_types.append(res)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func get_ammo_types() -> Array[AmmoType]:
	return _ammo_types
