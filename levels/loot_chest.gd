extends CSGBox3D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData

func use(player:Player) -> void:
	toggle_inventory.emit(self)
