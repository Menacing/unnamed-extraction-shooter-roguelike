extends Node

const ITEM_MAPPING_RESOURCE_GROUP = preload("res://game_objects/items/item_mapping_resource_group.tres")

var _item_mappings:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# declare a type safe array
	var item_infos:Array[ItemMapping] = []
	# fills the array with the resources from the resource group
	ITEM_MAPPING_RESOURCE_GROUP.load_all_into(item_infos)
	_map_item_mapping_array(item_infos)
	if _item_mappings.size() == 0:
		push_error("NO ITEM MAPPINGS FOUND")
		
func _map_item_mapping_array(im:Array[ItemMapping]):
	for map:ItemMapping in im:
		if map:
			_item_mappings[map.item_type_id] = map
			
func get_item_3d(item_type_id:String) -> PackedScene:
	if _item_mappings.has(item_type_id):
		return _item_mappings[item_type_id].item_3d_scene
	else:
		return null

func get_item_information(item_type_id:String) -> ItemInformation:
	if _item_mappings.has(item_type_id):
		return _item_mappings[item_type_id].item_information
	else:
		return null

func get_all_item_information() -> Array[ItemInformation]:
	var item_infos:Array[ItemInformation] = []
	for key in _item_mappings.keys():
		var map:ItemMapping = _item_mappings[key]
		if map:
			item_infos.append(map.item_information)
	return item_infos
