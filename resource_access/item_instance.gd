extends Object
class_name ItemInstance
var id_3d:int
var id_2d:int
var _item_info:ItemInformation
var stacks:int
var durability:int
var current_inventory_id:int

func get_item_type() -> ItemInformation.ItemType:
	return _item_info.item_type

func get_width() -> int:
	return _item_info.column_span
	
func get_height() -> int:
	return _item_info.row_span
	
func get_item_type_id() -> int:
	return _item_info.item_type_id

func get_max_allowed_stacks() -> int:
	return _item_info.max_stacks

func get_texture() -> Texture:
	return _item_info.icon
	
func get_texture_r() -> Texture:
	return _item_info.icon_r
