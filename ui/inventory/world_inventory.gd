extends InventoryControlBase
class_name WorldInventory

var _wig:WorldInventoryGrid
@onready var wig:WorldInventoryGrid:
	get:
		if _wig:
			return _wig
		else:
			_wig = %WorldInventoryGrid
			return _wig
var container_size:int:
	get:
		return wig.container_size
	set(value):
		wig.container_size = value
		wig.set_grid_container_size(value)
		
@onready var original_parent:Node = self.get_parent()

func _ready():
	super()
	container_size = _inventory.initial_height * _inventory.initial_width

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == _inventory.get_instance_id() and result.picked_up:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_control:ItemControl = instance_from_id(item_instance.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.GRID:
			wig.add_item_control(item_control, location.grid_x, location.grid_y)

func _on_open_inventory(inventory_id:int):
	super(inventory_id)
	if inventory_id == self.inventory_id:
		EventBus.add_inventory_to_HUD.emit(self)
		
func _on_close_inventory(inventory_id:int):
	super(inventory_id)
	if inventory_id == self.inventory_id:
		EventBus.remove_inventory_from_HUD.emit(self, original_parent)

func _on_close_all_inventories():
	super()
	EventBus.remove_inventory_from_HUD.emit(self, original_parent)
	
