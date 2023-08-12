extends Object
class_name InventoryAccess

var inventories:Dictionary = {}

func add_inventory(inventory:Inventory):
	inventories[inventory.get_instance_id()] = inventory
	
func get_inventory(inventory_id:int) -> Inventory:
	if inventory_id != 0:
		return inventories[inventory_id]
	else:
		return null

func _clear_inventory(inventory_id:int):
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return
		
	for slot in inventory.equipment_slots:
		slot.item_instance_id = 0
		

	for w in range(inventory.get_width()):
		for h in range(inventory.get_height()):
			inventory.grid_slots[w][h] = null

func can_place_item_in_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return false
		
	var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
	if slot:
		#check if slot is empty
		if slot.item_instance_id == 0:
			if item_inst.get_item_type() in slot.allowed_types: 
				return true	
	return false
	
func can_place_stack_in_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null or item_inst == null or !item_inst.get_has_stacks():
		return false
		
	var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
	if slot:
		#check if slot is empty
		if slot.item_instance_id == 0:
			if item_inst.get_item_type() in slot.allowed_types: 
				return true
		#check if we can combine stacks
		else:
			var destination_item:ItemInstance = ItemAccess.get_item(slot.item_instance_id)
			return ItemAccess.can_combine_stacks(item_inst,destination_item)
	return false

func place_item_in_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String) -> bool:
	var inventory = get_inventory(inventory_id)	
	if can_place_item_in_slot(item_inst,inventory_id,slot_name):
		var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
		if slot:
			remove_item(item_inst,item_inst.current_inventory_id)
			slot.item_instance_id = item_inst.get_instance_id()
			return true
	return false
	
func place_stack_in_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String, amount:int) -> bool:
	var inventory = get_inventory(inventory_id)
	if can_place_stack_in_slot(item_inst,inventory_id,slot_name):
		var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
		if slot:
			#check if slot is empty
			if slot.item_instance_id == 0:
				#if slot empty and we're moving everything in source stack, just move the instance
				if amount >= item_inst.stacks:
					remove_item(item_inst,item_inst.current_inventory_id)
					slot.item_instance_id = item_inst.get_instance_id()
					return true
				#else we're moving only some to a new instance
				else:
					var new_inst = ItemAccess.clone_instance(item_inst)
					slot.item_instance_id = new_inst.get_instance_id()
					new_inst.stacks = amount
					item_inst.stacks -= amount
					return false
			#else we have to combine stacks
			else:
				var destination_item:ItemInstance = ItemAccess.get_item(slot.item_instance_id)
				var remainder = ItemAccess.combine_stacks(item_inst, destination_item, amount)
				
				if remainder == 0:
					return true
				else:
					return false
	return false

func can_place_item_in_grid(item_inst:ItemInstance, inventory_id:int, grid_location:Vector2i) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return false
		
	var x = grid_location.x
	var y = grid_location.y
	var w = item_inst.get_width()
	var h = item_inst.get_height()
	#invalid coordinates
	if x < 0 or y < 0:
		return false
	#item bigger than available space
	if x + w > inventory.get_width() or y + h > inventory.get_height():
		return false
	
	#check if there's an item alredy there
	for i in range(x, x + w):
		for j in range(y, y + h):
			var grid_val = inventory.grid_slots[i][j]
			if grid_val:
				return false
	#if nothing is found, the space is clear
	return true
	
func can_place_stack_in_grid(item_inst:ItemInstance, inventory_id:int, grid_location:Vector2i) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return false
		
	var x = grid_location.x
	var y = grid_location.y
	var w = item_inst.get_width()
	var h = item_inst.get_height()
	#invalid coordinates
	if x < 0 or y < 0:
		return false
	#item bigger than available space
	if x + w > inventory.get_width() or y + h > inventory.get_height():
		return false
	
	#check if there's an item alredy there
	for i in range(x, x + w):
		for j in range(y, y + h):
			var grid_val = inventory.grid_slots[i][j]
			if grid_val != null:
				#if something is there, check if we can combine stacks
				return ItemAccess.can_combine_stacks(item_inst,grid_val)

	#if nothing is found, the space is clear
	return true

func place_item_in_grid(item_inst:ItemInstance, inventory_id:int, grid_location:Vector2i) -> bool:
	#if we can place the item in the grid, set the cells
	if can_place_item_in_grid(item_inst, inventory_id, grid_location):
		var inventory = get_inventory(inventory_id)
		var x = grid_location.x
		var y = grid_location.y
		var w = item_inst.get_width()
		var h = item_inst.get_height()
		for i in range(x, x + w):
			for j in range(y, y + h):
				inventory.grid_slots[i][j] = item_inst
		return true
	else:
		return false

func place_stack_in_grid(item_inst:ItemInstance, inventory_id:int, grid_location:Vector2i, amount:int) -> bool:
	#if we can place the item in the grid, set the cells
	if can_place_stack_in_grid(item_inst, inventory_id, grid_location):
		var inventory = get_inventory(inventory_id)
		var x = grid_location.x
		var y = grid_location.y
		var w = item_inst.get_width()
		var h = item_inst.get_height()
		for i in range(x, x + w):
			for j in range(y, y + h):
				var grid_val = inventory.grid_slots[i][j]
				if grid_val == null:
					#if cell empty and we're moving everything in source stack, just move the instance
					if amount >= item_inst.stacks:
						remove_item(item_inst,item_inst.current_inventory_id)
						inventory.grid_slots[i][j] = item_inst
						return true
					#else we're moving only some to a new instance
					else:
						var new_inst = ItemAccess.clone_instance(item_inst)
						new_inst.stacks = amount
						inventory.grid_slots[i][j] = new_inst
						item_inst.stacks -= amount
						return false
				#else we have to combine stacks
				else:
					var remainder = ItemAccess.combine_stacks(item_inst, grid_val, amount)

					if remainder == 0:
						return true
					else:
						return false
		return true
	else:
		return false
	
func remove_item(item:ItemInstance,  inventory_id:int) -> void:
	remove_item_from_slot(item,inventory_id)
	remove_item_from_grid(item,inventory_id)

func remove_item_from_grid(item:ItemInstance,  inventory_id:int) -> void:
	var inventory = get_inventory(inventory_id)
	if inventory:
		for x in range (0, inventory.get_width()):
			for y in range(0,inventory.get_height()):
				var cell = inventory.grid_slots[x][y]
				if cell is ItemInstance and cell.get_instance_id() == item.get_instance_id():
					inventory.grid_slots[x][y] = null
	
	item.current_inventory_id = 0

func remove_item_from_slot(item:ItemInstance, inventory_id:int) -> void:
	var inventory = get_inventory(inventory_id)
	if inventory:
		for slot in inventory.equipment_slots:
			if slot.item_instance_id == item.get_instance_id():
				slot.item_instance_id = 0

	item.current_inventory_id = 0

