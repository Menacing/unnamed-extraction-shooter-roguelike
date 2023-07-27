extends InventoryControlBase

@onready var inventory_grid:InventoryGridContainer = $PanelContainer/InventoryBase/PanelContainer/InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	_inventory.setup()
	EventBus.add_inventory.emit(_inventory)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	pass # Replace with function body.

func _on_item_picked_up(result:InventoryInsertResult):
	var self_object_id = self.get_instance_id()
	var inv_id = _inventory.get_instance_id()
	if result.inventory_id == _inventory.get_instance_id():
		print("item picked up")
		
		var item_control:ItemControl = instance_from_id(result.item.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.SLOT:
			#TODO: Move ItemControl to slot Control
			var slot_type:EquipmentSlotType = instance_from_id(location.slot_id)
			if slot_type:
				var slot_control:EquipmentSlotControl = self.find_child(slot_type.name)
				if slot_control:
					slot_control.add_item_control(item_control)
		elif location.location == InventoryLocationResult.LocationType.GRID:
			inventory_grid.add_item_control(item_control, location.grid_x, location.grid_y)
