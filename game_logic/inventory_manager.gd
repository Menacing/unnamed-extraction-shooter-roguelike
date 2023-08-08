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
	var pickup_result:InventoryInsertResult = _inventory_access.pickup_item(item_inst, target_inventory_id)
	_handle_insert_result(pickup_result, item_inst, null)
		
func _handle_insert_result(pickup_result:InventoryInsertResult, item_inst:ItemInstance, source_inventory:Inventory):
	if pickup_result.status == InventoryInsertResult.PickupItemResult.PICKED_UP:
		var source_inventory_id = source_inventory.get_instance_id() if source_inventory else 0
		if source_inventory_id != pickup_result.inventory_id:
			remove_item(item_inst.get_instance_id(), source_inventory_id)
		item_inst.current_inventory_id = pickup_result.inventory_id
		EventBus.item_picked_up.emit(pickup_result)
	elif pickup_result.status == InventoryInsertResult.PickupItemResult.STACK_COMBINED:
		var combine_result:ItemCombineStackResult = _item_access.combine_stacks(pickup_result.sourceStack, pickup_result.destinationStack)
		if combine_result.result == ItemCombineStackResult.ResultTypes.FULLY_COMBINED:
			destroy_item(item_inst.get_instance_id())
			EventBus.item_stack_count_changed.emit(pickup_result.destinationStack)
			pass
		elif combine_result.result == ItemCombineStackResult.ResultTypes.PARTIALLY_COMBINED:
			pass
		elif combine_result.result == ItemCombineStackResult.ResultTypes.NOT_COMBINED:
			pass
		pass
	#TODO Handle stack stuff

func can_place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String) -> bool:
	return _inventory_access.can_place_item_in_slot(get_item(item_instance_id), target_inventory_id, slot_name)
	
func place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String):
	var item_inst = get_item(item_instance_id)
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	var source_inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
	var result:InventoryInsertResult = _inventory_access.place_item_in_slot(item_inst, target_inventory, slot_name)
	_handle_insert_result(result, item_inst, source_inventory)
	
func can_place_item_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i) -> bool:
	var item_inst = get_item(item_instance_id)	
	return _inventory_access.can_place_item_at_grid(item_inst, target_inventory_id, grid_location)
	
func place_item_at_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i):
	var item_inst = get_item(item_instance_id)	
	var target_inventory = _inventory_access.get_inventory(target_inventory_id)
	var source_inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
	var result:InventoryInsertResult = _inventory_access.place_item_at_grid(item_inst, target_inventory, grid_location)
	_handle_insert_result(result, item_inst, source_inventory)

func add_inventory(inventory:Inventory):
	_inventory_access.add_inventory(inventory)

func remove_item(item_instance_id:int, source_inventory_id:int):
	var item_inst = get_item(item_instance_id)	
	var source_inventory = _inventory_access.get_inventory(source_inventory_id)
	
	_inventory_access.remove_item(item_inst, source_inventory)
	if source_inventory:
		EventBus.item_removed_from_inventory.emit(item_inst,source_inventory.get_instance_id())
	

func destroy_item(item_instance_id:int):
	var item_inst = get_item(item_instance_id)		
	if item_inst.current_inventory_id != 0:
		var inventory = _inventory_access.get_inventory(item_inst.current_inventory_id)
		remove_item(item_inst, inventory)
	_item_access.destroy_item(item_inst)
	
func get_item(item_instance_id:int) -> ItemInstance:
	return _item_access.get_item(item_instance_id)
