extends Panel
class_name EquipmentSlotControl

@export var parent_inventory_control_base:InventoryControlBase

func _can_drop_data(at_position, data) -> bool:
	var item_instance_id:int = data["item_instance_id"]
	var target_inventory_id = parent_inventory_control_base._inventory.get_instance_id()
	var number_to_drop:int = 0
	if data.has("number_to_drop"):
		number_to_drop = data["number_to_drop"]
		
	#its a stack
	if number_to_drop > 0:
		return InventoryManager.can_place_stack_in_slot(item_instance_id, target_inventory_id, self.name, number_to_drop)
	#its not a stack
	else:
		return InventoryManager.can_place_item_in_slot(item_instance_id, target_inventory_id, self.name)

func _drop_data(at_position, data):
	print(data)	
	var item_instance_id:int = data["item_instance_id"]
	var target_inventory_id = parent_inventory_control_base._inventory.get_instance_id()
	var number_to_drop:int = 0
	if data.has("number_to_drop"):
		number_to_drop = data["number_to_drop"]
		
	#its a stack
	if number_to_drop > 0:
		if InventoryManager.can_place_stack_in_slot(item_instance_id, target_inventory_id, self.name, number_to_drop):
			InventoryManager.place_stack_in_slot(item_instance_id, target_inventory_id, self.name, number_to_drop)
	#its not a stack
	else:
		if InventoryManager.can_place_item_in_slot(item_instance_id, target_inventory_id, self.name):
			InventoryManager.place_item_in_slot(item_instance_id, target_inventory_id, self.name)

func add_item_control(item_control:ItemControl):
	item_control.reparent(self)
	var new_pos = Vector2()
	new_pos.x = (self.size.x/2) - (item_control.size.x/2)
	new_pos.y = (self.size.y/2) - (item_control.size.y/2)
	item_control.position = new_pos
