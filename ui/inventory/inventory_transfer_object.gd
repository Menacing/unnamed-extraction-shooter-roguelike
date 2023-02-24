extends RefCounted
class_name InventoryTransferObject

var inv_item:InvItemBase
var item_component:ItemComponent
var _rotated:bool = false

func toggle_rotation(cell_size:int):
	if _rotated:
		inv_item.item_texture_rect.texture = item_component.icon
		var orig_col = item_component.column_span
		item_component.column_span = item_component.row_span
		item_component.row_span = orig_col
	else:
		inv_item.item_texture_rect.texture = item_component.icon_r
		var orig_col = item_component.column_span
		item_component.column_span = item_component.row_span
		item_component.row_span = orig_col
	inv_item.size.x = item_component.column_span * cell_size
	inv_item.size.y = item_component.row_span * cell_size
	_rotated = !_rotated

func is_rotated() -> bool:
	return _rotated
	
func get_item_offset() -> Vector2:
	return Vector2(-inv_item.size.x/2,-inv_item.size.y/2)

