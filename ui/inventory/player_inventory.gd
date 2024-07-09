extends InventoryControlBase

func get_inventory_grid() -> InventoryGridContainer:
	return $PanelContainer/InventoryBase/PanelContainer/InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	EventBus.inventory_size_changed.connect(_on_inventory_size_changed)
	EventBus.item_removed_from_slot.connect(_on_item_removed_from_slot)
	
		
func _on_item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String):
	if inventory_id == _inventory.inventory_id:
		if slot_name == "BackpackSlot":
			InventoryManager.set_inventory_size(_inventory.inventory_id, Vector2i(7,2))

func _on_inventory_size_changed(inventory_id:int, size:Vector2i) -> void:
	if inventory_id == _inventory.inventory_id:
		get_inventory_grid().set_grid_container_size(size.x * size.y)
