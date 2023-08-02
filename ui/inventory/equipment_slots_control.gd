extends Panel
class_name EquipmentSlotControl

@export var parent_inventory_control_base:InventoryControlBase

func _can_drop_data(at_position, data) -> bool:
	print(data)	
	var item_inst:ItemInstance = data["item_inst"]

	return InventoryManager.can_place_item_in_slot(item_inst, parent_inventory_control_base._inventory.get_instance_id(), self.name)

func _drop_data(at_position, data):
	print(data)	
	var item_inst:ItemInstance = data["item_inst"]
	var target_inventory_id = parent_inventory_control_base._inventory.get_instance_id()

	var can_drop = InventoryManager.can_place_item_in_slot(item_inst, target_inventory_id, self.name)
	if can_drop:
		InventoryManager.place_item_in_slot(item_inst, target_inventory_id, self.name)


func add_item_control(item_control:ItemControl):
	item_control.reparent(self)
	var new_pos = Vector2()
	new_pos.x = (self.size.x/2) - (item_control.size.x/2)
	new_pos.y = (self.size.y/2) - (item_control.size.y/2)
	item_control.position = new_pos
