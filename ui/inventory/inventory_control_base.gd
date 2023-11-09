extends Control
class_name InventoryControlBase

@export var _inventory:Inventory
@export var _inventory_grid_path:NodePath

func get_inventory_grid() -> InventoryGridContainer:
	if _inventory_grid_path:
		return get_node(_inventory_grid_path)
	else:
		return null

var inventory_id:int :
	get:
		return _inventory.get_instance_id()

func _ready():
	_inventory.setup()
	EventBus.add_inventory.emit(_inventory)
	EventBus.open_inventory.connect(_on_open_inventory)
	EventBus.close_inventory.connect(_on_close_inventory)
	EventBus.close_all_inventories.connect(_on_close_all_inventories)
	EventBus.item_removed_from_inventory.connect(_on_item_removed_from_inventory)
	EventBus.item_picked_up.connect(_on_item_picked_up)

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == _inventory.get_instance_id() and result.picked_up:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_control:ItemControl = instance_from_id(item_instance.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.SLOT:
			var slot_type:EquipmentSlotType = Inventory.get_slot_by_name(_inventory, location.slot_name)
			if slot_type:
				var slot_control = self.find_child(slot_type.name)
				if slot_control:
					slot_control.add_item_control(item_control)
		elif location.location == InventoryLocationResult.LocationType.GRID and get_inventory_grid():
			get_inventory_grid().add_item_control(item_control, location.grid_x, location.grid_y)

func _on_open_inventory(inventory_id:int):
	if inventory_id == self.inventory_id:
		visible = true
		
func _on_close_inventory(inventory_id:int):
	if inventory_id == self.inventory_id:
		visible = false

func _on_close_all_inventories():
	visible = false

func _on_item_removed_from_inventory(item_inst:ItemInstance, inventory_id:int):
	if inventory_id == _inventory.get_instance_id():
		var item_control:ItemControl = instance_from_id(item_inst.id_2d)
		if item_control:
			var parent = item_control.get_parent()
			if parent:
				parent.remove_child(item_control)


