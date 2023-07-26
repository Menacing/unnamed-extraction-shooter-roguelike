extends GridContainer
class_name InventoryGridContainer

var cell_size:int:
	get:
		return self.get_child(0).custom_minimum_size.x

func add_item_control(item_control:Control, x:int, y:int):
	var cell = _get_grid_cell_control(x,y)
	item_control.reparent(cell)
	item_control.position = Vector2(0,0)
	
func _get_grid_cell_control(x:int, y:int) -> Control:
	var index = (y)*columns + x
	return self.get_child(index)

func _get_grid_coordinates(pos:Vector2) -> Vector2i:
	var local_pos = pos - global_position
	var results = Vector2i()
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results
