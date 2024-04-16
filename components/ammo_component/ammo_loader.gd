extends Node

var _ammo_types:Array[AmmoType]
var _path = "res://components/ammo_component/ammo_types/"
var _ammo_type_map:Dictionary = {}
var _ammo_subtype_map:Dictionary = {}

func _ready():
	load_ammo_info_from_path(_path)
	_build_ammo_map()

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

func _build_ammo_map():
	for at in _ammo_types:
		_ammo_type_map[at.name] = at
		_ammo_subtype_map[at.name] = {}
		for st in at.sub_types:
			_ammo_subtype_map[at.name][st.name] = st

func get_ammo_types() -> Array[AmmoType]:
	return _ammo_types

func get_ammo_subtype(ammo_type:String, ammo_subtype:String) -> AmmoSubtype:
	return _ammo_subtype_map[ammo_type][ammo_subtype]

func get_ammo_type(ammo_type:String) -> AmmoType:
	return _ammo_type_map[ammo_type]
