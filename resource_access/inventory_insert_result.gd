extends Object
class_name InventoryInsertResult

func _init(item:ItemInstance, _inventory_id:int, _location:InventoryLocationResult):
	item_instance_id = item.get_instance_id()
	inventory_id = _inventory_id
	location = _location

var item_instance_id:int
var inventory_id:int
var picked_up:bool
var location:InventoryLocationResult
