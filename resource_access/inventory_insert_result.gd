extends Object
class_name InventoryInsertResult

func _init(_item:ItemInstance, _inventory_id:int):
	item = _item
	inventory_id = _inventory_id

var item:ItemInstance
var inventory_id:int
var picked_up:bool
var location:InventoryLocationResult
