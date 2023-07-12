extends Object
class_name InventoryLocationResult

enum LocationType{
	GRID,
	SLOT
}

var location:LocationType

var grid_x:int:
	get:
		if location == LocationType.GRID:
			return grid_x
		else:
			return 0
	set(value):
		grid_x = value
var grid_y:int:
	get:
		if location == LocationType.GRID:
			return grid_y
		else:
			return 0
	set(value):
		grid_y = value
var slot_id:int:
	get:
		if location == LocationType.SLOT:
			return slot_id
		else:
			return 0
	set(value):
		slot_id = value
