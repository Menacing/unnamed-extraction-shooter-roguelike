extends MarginContainer

func _can_drop_data(at_position, data) -> bool:
	return true
	
func _drop_data(at_position, data):
	var item_instance_id:int = data["item_instance_id"]
	var item_instance:ItemInstance = InventoryManager.get_item(item_instance_id)
	if item_instance:
		var original_inventory_id = item_instance.current_inventory_id
		InventoryManager.remove_item(item_instance_id, original_inventory_id)
		EventBus.drop_item.emit(item_instance, original_inventory_id)
		
