extends CanvasLayer

@onready var player_inventory_id = $MarginContainer/HBoxContainer/PlayerInventoryContainer/PlayerInventory.inventory_id
@onready var world_inventories_container:Container = $MarginContainer/HBoxContainer/WorldInventoryContainer

func _ready():
	EventBus.add_inventory_to_HUD.connect(_on_add_inventory_to_HUD)
	EventBus.remove_inventory_from_HUD.connect(_on_remove_inventory_from_HUD)
	
	
func _on_add_inventory_to_HUD(inventory_control:InventoryControlBase):
	Helpers.force_parent(inventory_control,world_inventories_container)
	
func _on_remove_inventory_from_HUD(inventory_control:InventoryControlBase, new_parent:Node):
	Helpers.force_parent(inventory_control,new_parent)
