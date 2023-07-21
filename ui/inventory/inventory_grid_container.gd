extends GridContainer
class_name InventoryGridContainer

func add_item_control(item_control:Control, x:int, y:int):
	var cell = _get_grid_cell_control(x,y)
	item_control.reparent(cell)
	item_control.position = Vector2(0,0)
	
func _get_grid_cell_control(x:int, y:int) -> Control:
	var index = (y)*columns + x
	return self.get_child(index)


