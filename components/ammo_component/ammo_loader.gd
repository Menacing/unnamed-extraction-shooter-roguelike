extends Node

var _ammo_types:Array[AmmoType]
var _ammo_type_map:Dictionary = {}
var _ammo_subtype_map:Dictionary = {}

var resource_group:ResourceGroup = load("res://components/ammo_component/ammo_types/ammo_resource_group.tres")

func _ready():
	resource_group.load_all_into(_ammo_types)
	_build_ammo_map()

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
