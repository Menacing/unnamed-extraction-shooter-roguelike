extends ItemContextItem
class_name RegelUseItemContextItem


func custom_context_function(inventory_data:InventoryData, slot_data:SlotData, player:Player):
	super(inventory_data, slot_data, player)
	player.main_health_component.apply_healing(75.0)
	
	var new_quantity = slot_data.quantity - 1
	if new_quantity == 0:
		inventory_data.grab_slot_data(slot_data.root_index)
	slot_data.quantity = new_quantity
	inventory_data.inventory_updated.emit(inventory_data)
	
