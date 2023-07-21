extends InventoryControlBase

@export var _player_inventory:Inventory

@onready var inventory_grid:InventoryGridContainer = $PanelContainer/InventoryBase/PanelContainer/InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_inventory.setup()
	EventBus.add_inventory.emit(_player_inventory)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	pass # Replace with function body.

func _on_item_picked_up(result:InventoryInsertResult):
	var self_object_id = self.get_instance_id()
	var inv_id = _player_inventory.get_instance_id()
	if result.inventory_id == _player_inventory.get_instance_id():
		print("item picked up")
		
		var item_control:Control = instance_from_id(result.item.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.SLOT:
			var slot:EquipmentSlot = instance_from_id(location.slot_id)
		elif location.location == InventoryLocationResult.LocationType.GRID:
			inventory_grid.add_item_control(item_control, location.grid_x, location.grid_y)
