extends Object
class_name InventoryInsertResult

enum PickupItemResult {
	NOT_PICKED_UP,
	PICKED_UP,
	STACK_COMBINED
}

func _init(_item:ItemInstance, _inventory_id:int):
	item = _item
	inventory_id = _inventory_id

var item:ItemInstance
var inventory_id:int
var status:PickupItemResult
var location:InventoryLocationResult
var sourceStack:ItemInstance
var destinationStack:ItemInstance
