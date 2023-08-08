extends Object
class_name ItemInstance
var id_3d:int
var id_2d:int
var _item_info:ItemInformation
var stacks:int
var durability:int
var current_inventory_id:int
var is_rotated:bool

func get_show_name() -> bool:
	return _item_info.show_name
	
func get_display_name() -> String:
	return _item_info.display_name
	
func get_item_type() -> ItemInformation.ItemType:
	return _item_info.item_type

func get_width() -> int:
	if !is_rotated:
		return _item_info.column_span
	else:
		return _item_info.row_span
	
func get_height() -> int:
	if !is_rotated:
		return _item_info.row_span
	else:
		return _item_info.column_span
	
func get_item_type_id() -> int:
	return _item_info.item_type_id

func get_max_allowed_stacks() -> int:
	return _item_info.max_stacks

func get_has_stacks() -> bool:
	return _item_info.has_stacks
	
func get_max_durability() -> int:
	return _item_info.max_durability
	
func get_has_durability() -> bool:
	return _item_info.has_durability

func get_texture() -> Texture:
	if !is_rotated:
		return _item_info.icon
	else:
		return _item_info.icon_r


