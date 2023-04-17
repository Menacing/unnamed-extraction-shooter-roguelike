extends RefCounted
class_name InventoryTransferObject

var inv_item:InvItemBase
var item_component:ItemComponent
var _rotated:bool = false

var cell_width:int
var cell_height:int

func toggle_rotation(cell_size:int):
	if _rotated:
		inv_item.item_texture_rect.texture = item_component.inventory_info.icon
	else:
		inv_item.item_texture_rect.texture = item_component.inventory_info.icon_r
	var orig_col = cell_width
	cell_width = cell_height
	cell_height = orig_col
	inv_item.size.x = cell_width * cell_size
	inv_item.size.y = cell_height * cell_size
	_rotated = !_rotated

func is_rotated() -> bool:
	return _rotated
	
func get_item_offset() -> Vector2:
	return Vector2(-inv_item.size.x/2,-inv_item.size.y/2)

