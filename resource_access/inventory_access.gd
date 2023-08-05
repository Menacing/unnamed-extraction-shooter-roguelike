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

func pickup_item(item:ItemInstance, inventory_id:int) -> InventoryInsertResult:
	var result = InventoryInsertResult.new(item, inventory_id)
	
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return result
	
	#First check item slots
	if inventory.equipment_slots:
		for slot in inventory.equipment_slots:
			if item.get_item_type() in slot.allowed_types and slot.item_instance_id != 0:
				slot.item = item
				result.status = InventoryInsertResult.PickupItemResult.PICKED_UP
				result.location = InventoryLocationResult.new()
				result.location.location = InventoryLocationResult.LocationType.SLOT
				result.location.slot_id = slot.get_instance_id()
				return result

	#Next try to insert in first grid space
	return _insert_item_at_first_available_grid_location(item, inventory)
	
func can_place_item_in_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return false
	return _can_place_item_in_slot(item_inst, inventory, slot_name)
	
static func _can_place_item_in_slot(item_inst:ItemInstance, inventory:Inventory, slot_name:String) -> bool:
	var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
	if slot:
		if slot.item_instance_id != 0:
			if item_inst.get_item_type() in slot.allowed_types: 
				return true	
	return false

static func place_item_in_slot(item_inst:ItemInstance, inventory:Inventory, slot_name:String) -> InventoryInsertResult:
	var result = InventoryInsertResult.new(item_inst, inventory.get_instance_id())	
	if _can_place_item_in_slot(item_inst,inventory,slot_name):
		var slot:EquipmentSlotType = Inventory.get_slot_by_name(inventory,slot_name)
		if slot:
			_remove_item_from_slot(item_inst,inventory)
			slot.item = item_inst
			result.status = InventoryInsertResult.PickupItemResult.PICKED_UP
			result.location = InventoryLocationResult.new()
			result.location.location = InventoryLocationResult.LocationType.SLOT
			result.location.slot_id = slot.get_instance_id()
			return result
	return result

static func _insert_item_at_first_available_grid_location(item:ItemInstance, inventory:Inventory) -> InventoryInsertResult:
	var result = InventoryInsertResult.new(item, inventory.get_instance_id())
	
	for y in range(inventory.get_height()):
		for x in range(inventory.get_width()):
			var grid_loc = Vector2i(x,y)
			var try_result = _try_insert_at_grid(item, inventory, grid_loc)
			#if we do anything besides finding space for it, return that result
			if try_result.status != InventoryInsertResult.PickupItemResult.NOT_PICKED_UP:
				return try_result
	#TODO try rotating and repeating
	
	return result
	
func can_place_item_at_grid(item_inst:ItemInstance, inventory_id:int, grid_location:Vector2i) -> bool:
	var inventory = get_inventory(inventory_id)
	if inventory == null:
		return false
	var result:InventoryInsertResult = _can_place_item_at_grid(item_inst, inventory, grid_location)
	if result.status != InventoryInsertResult.PickupItemResult.NOT_PICKED_UP:
		return true
	else:
		return false
	
static func _can_place_item_at_grid(item:ItemInstance, inventory:Inventory, grid_location:Vector2i) -> InventoryInsertResult:
	var result = InventoryInsertResult.new(item, inventory.get_instance_id())
	
	var x = grid_location.x
	var y = grid_location.y
	var w = item.get_width()
	var h = item.get_height()
	#invalid coordinates
	if x < 0 or y < 0:
		return result
	#item bigger than available space
	if x + w > inventory.get_width() or y + h > inventory.get_height():
		return result
	
	#see if we can combine stacks, otherwise check if there's an item alredy there
	for i in range(x, x + w):
		for j in range(y, y + h):
			var grid_val = inventory.grid_slots[i][j]
			if _should_insert_stacks(item, grid_val):
				result.status = InventoryInsertResult.PickupItemResult.STACK_COMBINED
				result.sourceStack = item
				result.destinationStack = grid_val
				result.location = InventoryLocationResult.new()
				result.location.location = InventoryLocationResult.LocationType.GRID
				result.location.grid_x = x
				result.location.grid_y = y
				return result
			elif grid_val:
				return result
	#if nothing is found, the space is clear, set the inventory and report it's picked up
	result.status = InventoryInsertResult.PickupItemResult.PICKED_UP
	result.location = InventoryLocationResult.new()
	result.location.location = InventoryLocationResult.LocationType.GRID
	result.location.grid_x = x
	result.location.grid_y = y
	return result
	
func place_item_at_grid(item_inst:ItemInstance, inventory:Inventory, grid_location:Vector2i) -> InventoryInsertResult:
	var result = InventoryInsertResult.new(item_inst, inventory.get_instance_id())	
	if _can_place_item_at_grid(item_inst, inventory, grid_location):
		_remove_item_from_grid(item_inst, inventory)
		result = _try_insert_at_grid(item_inst, inventory, grid_location)
	return result

static func _try_insert_at_grid(item:ItemInstance, inventory:Inventory, grid_location:Vector2i) -> InventoryInsertResult:
	var result = _can_place_item_at_grid(item, inventory, grid_location)
	if result.status == InventoryInsertResult.PickupItemResult.PICKED_UP:
		var w = item.get_width()
		var h = item.get_height()
		_set_grid_slots(grid_location.x, grid_location.y, w, h, item, inventory)
	return result

static func _should_insert_stacks(source_stack:ItemInstance, destination_stack:ItemInstance) -> bool:
	if destination_stack and destination_stack.get_item_type_id() == source_stack.get_item_type_id() and source_stack.get_max_allowed_stacks() > 1 :
		if destination_stack.stacks < destination_stack.get_max_allowed_stacks():
			return true
		else:
			return false
	else:
		return false

static func _set_grid_slots(x, y, w, h, item:ItemInstance, inventory:Inventory) -> void:
	for i in range(x, x + w):
		for j in range(y, y + h):
			inventory.grid_slots[i][j] = item

static func remove_item(item:ItemInstance, inventory:Inventory) -> void:
	_remove_item_from_slot(item,inventory)
	_remove_item_from_grid(item,inventory)

static func _remove_item_from_grid(item:ItemInstance, inventory:Inventory) -> void:
	if inventory:
		for x in range (0, inventory.get_width()):
			for y in range(0,inventory.get_height()):
				var cell = inventory.grid_slots[x][y]
				if cell is ItemInstance and cell.get_instance_id() == item.get_instance_id():
					inventory.grid_slots[x][y] = null
	
	item.current_inventory_id = 0

static func _remove_item_from_slot(item:ItemInstance, inventory:Inventory) -> void:
	if inventory:
		for slot in inventory.equipment_slots:
			if slot.item_instance_id != 0:
				if slot.item.get_instance_id() == item.get_instance_id():
					slot.item = null
	
	item.current_inventory_id = 0
