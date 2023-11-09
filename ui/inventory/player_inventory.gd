extends InventoryControlBase

func get_inventory_grid() -> InventoryGridContainer:
	return $PanelContainer/InventoryBase/PanelContainer/InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	EventBus.inventory_size_changed.connect(_on_inventory_size_changed)
	EventBus.item_removed_from_slot.connect(_on_item_removed_from_slot)
	
#func _on_item_picked_up(result:InventoryInsertResult):
	#if result.inventory_id == _inventory.get_instance_id() and result.picked_up:
		#var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		#var item_control:ItemControl = instance_from_id(item_instance.id_2d)
		#var location = result.location
		#if location.location == InventoryLocationResult.LocationType.SLOT:
			#var slot_type:EquipmentSlotType = Inventory.get_slot_by_name(_inventory, location.slot_name)
			#if slot_type:
				#var slot_control:EquipmentSlotControl = self.find_child(slot_type.name)
				#if slot_control:
					#slot_control.add_item_control(item_control)
		#elif location.location == InventoryLocationResult.LocationType.GRID:
			#inventory_grid.add_item_control(item_control, location.grid_x, location.grid_y)
		
		
func _on_item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String):
	if inventory_id == _inventory.get_instance_id():
		if slot_name == "BackpackSlot":
			InventoryManager.set_inventory_size(_inventory.get_instance_id(), Vector2i(7,2))

func _on_inventory_size_changed(inventory_id:int, size:Vector2i) -> void:
	if inventory_id == _inventory.get_instance_id():
		get_inventory_grid().set_grid_container_size(size.x * size.y)
