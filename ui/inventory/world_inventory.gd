extends InventoryControlBase
class_name WorldInventory

var _wig:WorldInventoryGrid
@onready var wig:WorldInventoryGrid:
	get:
		if _wig:
			return _wig
		else:
			_wig = $InventoryBase/WorldInventoryGrid
			return _wig
var container_size:int:
	get:
		return wig.container_size
	set(value):
		wig.container_size = value
		wig.set_container_size(value)

