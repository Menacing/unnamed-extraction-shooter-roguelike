extends PanelContainer

const Slot = preload("res://ui/inventory/3.0/slot.tscn")

@onready var item_grid: GridContainer = %ItemGrid

func set_inventory_data(inventory_data:InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
	
func clear_inventory_data(inventory_data:InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data:InventoryData) -> void:
	for child in item_grid.get_children():
		#remove from the grid or they stick around long enough to mess up the indexing
		item_grid.remove_child(child)
		child.queue_free()
	
	var ri:int = 0
	var ci:int = 0
	for slot_data_row in inventory_data.slot_datas:
		ci = 0
		for slot_data_col in slot_data_row:
			var slot = Slot.instantiate()
			slot.name = "Slot_%s_%s" % [ri,ci]
			item_grid.add_child(slot)
			
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)
			
			if slot_data_col:
				slot.set_slot_data(slot_data_col)
			ci += 1
		ri += 1
