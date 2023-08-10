extends Node

var _inventory_access:InventoryAccess
var _item_access:ItemAccess

func _init():
	_inventory_access = InventoryAccess.new()
	_item_access = ItemAccess.new()

func _ready():
	EventBus.pickup_item.connect(_on_pickup_item)
	EventBus.add_inventory.connect(add_inventory)

func _on_pickup_item(item_inst:ItemInstance, target_inventory_id:int):
	#Are we dealing with a stack or not
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id)	
	var inventory = _inventory_access.get_inventory(target_inventory_id)
	if inventory == null:
		return
	if !item_inst.get_has_stacks():
		#First check item slots
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if _inventory_access.can_place_item_in_slot(item_inst, target_inventory_id, slot.name):
					pickup_result.picked_up = _inventory_access.place_item_in_slot(item_inst, target_inventory_id, slot.name)
					pickup_result.location = InventoryLocationResult.new()
					pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
					pickup_result.location.slot_id = slot.get_instance_id()
					EventBus.item_picked_up.emit(pickup_result)
					return
	#
		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc = Vector2i(x,y)
				if _inventory_access.can_place_item_in_grid(item_inst, target_inventory_id, grid_loc):
					pickup_result.picked_up = _inventory_access.place_item_in_grid(item_inst, target_inventory_id, grid_loc)
					pickup_result.location = InventoryLocationResult.new()
					pickup_result.location.location = InventoryLocationResult.LocationType.GRID
					pickup_result.location.grid_x = grid_loc.x
					pickup_result.location.grid_y = grid_loc.y
					EventBus.item_picked_up.emit(pickup_result)
					return
		##TODO try rotating and repeating
	#do stack stuff
	elif item_inst.stacks > 0:
		#First check item slots
		var amount = item_inst.stacks
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if item_inst.stacks > 0 and  _inventory_access.can_place_stack_in_slot(item_inst, target_inventory_id, slot.name, item_inst.stacks):
					pickup_result.picked_up = _inventory_access.place_stack_in_slot(item_inst, target_inventory_id, slot.name, item_inst.stacks)
					pickup_result.location = InventoryLocationResult.new()
					pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
					pickup_result.location.slot_id = slot.get_instance_id()
					EventBus.item_picked_up.emit(pickup_result)
		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc = Vector2i(x,y)
				if item_inst.stacks > 0 and _inventory_access.can_place_stack_in_grid(item_inst, target_inventory_id, grid_loc, item_inst.stacks):
					pickup_result.picked_up = _inventory_access.place_stack_in_grid(item_inst, target_inventory_id, grid_loc, item_inst.stacks)
					pickup_result.location = InventoryLocationResult.new()
					pickup_result.location.location = InventoryLocationResult.LocationType.GRID
					pickup_result.location.grid_x = grid_loc.x
					pickup_result.location.grid_y = grid_loc.y
					EventBus.item_picked_up.emit(pickup_result)
		##TODO try rotating and repeating
	pass


func can_place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String) -> bool:
	return _inventory_access.can_place_item_in_slot(get_item(item_instance_id), target_inventory_id, slot_name)

func can_place_stack_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String, amount:int) -> bool:
	return _inventory_access.can_place_stack_in_slot(get_item(item_instance_id), target_inventory_id, slot_name, amount)
	
func place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String):
	var item_inst = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id)
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	var source_inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
	pickup_result.picked_up = _inventory_access.place_item_in_slot(item_inst, target_inventory, slot_name)
	
	EventBus.item_picked_up.emit(pickup_result)
	
func place_stack_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String, amount: int):
	var item_inst = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id)
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	var source_inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
	pickup_result.picked_up = _inventory_access.place_stack_in_slot(item_inst, target_inventory, slot_name, amount)
	
	EventBus.item_picked_up.emit(pickup_result)
	
func can_place_item_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i) -> bool:
	var item_inst = get_item(item_instance_id)	
	return _inventory_access.can_place_item_at_grid(item_inst, target_inventory_id, grid_location)

func can_place_stack_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i, amount:int) -> bool:
	var item_inst = get_item(item_instance_id)	
	return _inventory_access.can_place_stack_in_grid(item_inst, target_inventory_id, grid_location, amount)
	
func place_item_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i):
	var item_inst = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id)	
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	pickup_result.picked_up = _inventory_access.place_item_at_grid(item_inst, target_inventory, grid_location)
	
	EventBus.item_picked_up.emit(pickup_result)
	
func place_stack_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i, amount: int):
	var item_inst = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id)	
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	pickup_result.picked_up = _inventory_access.place_stack_in_grid(item_inst, target_inventory, grid_location, amount)
	
	EventBus.item_picked_up.emit(pickup_result)

func add_inventory(inventory:Inventory):
	_inventory_access.add_inventory(inventory)

func remove_item(item_instance_id:int, source_inventory_id:int):
	var item_inst = get_item(item_instance_id)	
	_inventory_access.remove_item(item_inst, source_inventory_id)
	EventBus.item_removed_from_inventory.emit(item_inst, source_inventory_id)
	

func destroy_item(item_instance_id:int):
	var item_inst = get_item(item_instance_id)		
	if item_inst.current_inventory_id != 0:
		var inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
		remove_item(item_inst, inventory)
	_item_access.destroy_item(item_inst)
	
func get_item(item_instance_id:int) -> ItemInstance:
	return _item_access.get_item(item_instance_id)
