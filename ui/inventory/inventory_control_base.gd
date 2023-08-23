extends Control
class_name InventoryControlBase

@export var _inventory:Inventory

var inventory_id:int :
	get:
		return _inventory.get_instance_id()
