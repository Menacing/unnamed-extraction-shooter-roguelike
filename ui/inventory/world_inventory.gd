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
		
@onready var original_parent:Node3D = self.get_parent()
var player:Player

func _ready():
	super()
	EventBus.drop_item.connect(_on_drop_item)
	
func _on_before_populate_level():
	super()
	container_size = _inventory.initial_height * _inventory.initial_width

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == _inventory.inventory_id and result.picked_up:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_control:ItemControl = ItemAccess.get_item_control(item_instance.id_2d)
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
	
func _on_drop_item(item_inst:ItemInstance, _inventory_id:int):
	if _inventory_id == self.inventory_id:
		var item_3d:Item3D = ItemAccess.get_item_3d(item_inst.id_3d)
		Helpers.force_parent(item_3d,get_parent())
		item_3d.dropped()
		var aabb = Helpers.get_aabb_of_node(self)
		item_3d.global_position = player.drop_location.global_position
