extends Control
class_name InventoryControlBase

@export var _inventory:Inventory

var inventory_id:int :
	get:
		return _inventory.get_instance_id()

func _ready():
	_inventory.setup()
	EventBus.add_inventory.emit(_inventory)
	EventBus.open_inventory.connect(_on_open_inventory)
	EventBus.close_inventory.connect(_on_close_inventory)
	EventBus.close_all_inventories.connect(_on_close_all_inventories)
	

func _on_open_inventory(inventory_id:int):
	if inventory_id == self.inventory_id:
		visible = true
		
func _on_close_inventory(inventory_id:int):
	if inventory_id == self.inventory_id:
		visible = false

func _on_close_all_inventories():
	visible = false
