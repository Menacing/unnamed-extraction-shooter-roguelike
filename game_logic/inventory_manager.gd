extends Node

var _inventory_access:InventoryAccess
var _item_access:ItemAccess

func _init():
	_inventory_access = InventoryAccess.new()
	_item_access = ItemAccess.new()
	
func _ready():
	EventBus.pickup_item.connect(on_pickup_item)
	EventBus.add_inventory.connect(add_inventory)

func on_pickup_item(item_inst:ItemInstance, target_inventory_id:int):
	var pickup_result:InventoryInsertResult = _inventory_access.pickup_item(item_inst, target_inventory_id)
	if pickup_result.status == InventoryInsertResult.PickupItemResult.PICKED_UP:
		EventBus.item_picked_up.emit(pickup_result)
	elif pickup_result.status == InventoryInsertResult.PickupItemResult.STACK_COMBINED:
		var combine_result:ItemCombineStackResult = _item_access.combine_stacks(pickup_result.sourceStack, pickup_result.destinationStack)
		if combine_result.result == ItemCombineStackResult.ResultTypes.FULLY_COMBINED:
			destroy_item(item_inst)
			pass
		pass
		#TODO Handle stack stuff
		
func can_place_item_in_slot(item_inst:ItemInstance, target_inventory_id:int, slot_name:String) -> bool:
	return _inventory_access.can_place_item_in_slot(item_inst, target_inventory_id, slot_name)
	
func can_place_item_at_grid(item_inst:ItemInstance, target_inventory_id:int, grid_location:Vector2i) -> bool:
	return _inventory_access.can_place_item_at_grid(item_inst, target_inventory_id, grid_location)	

func add_inventory(inventory:Inventory):
	_inventory_access.add_inventory(inventory)

func destroy_item(item:ItemInstance):
	if item.current_inventory_id:
		#TODO Remove item from existing inventory
		#_inventory_access.remove
		pass
	_item_access.destroy_item(item)
	
func get_item(item_instance_id:int) -> ItemInstance:
	return _item_access.get_item(item_instance_id)
