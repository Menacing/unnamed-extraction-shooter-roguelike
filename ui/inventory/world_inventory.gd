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

func _ready():
	super()
	container_size = _inventory.initial_height * _inventory.initial_width
	EventBus.item_picked_up.connect(_on_item_picked_up)

func _on_item_picked_up(result:InventoryInsertResult):
	var inv_id = _inventory.get_instance_id()
	if result.inventory_id == _inventory.get_instance_id() and result.picked_up:
		
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_control:ItemControl = instance_from_id(item_instance.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.GRID:
			wig.add_item_control(item_control, location.grid_x, location.grid_y)
