extends CanvasLayer

@export var player:Player
@onready var player_inventory_id:int:
	get:
		return $MarginContainer/HBoxContainer/PlayerInventoryContainer/TabContainer/EQUIPMENT.inventory_id
	set(value):
		$MarginContainer/HBoxContainer/PlayerInventoryContainer/TabContainer/EQUIPMENT.inventory_id = value
@onready var world_inventories_container:Container = $MarginContainer/HBoxContainer/WorldInventoryContainer
@onready var player_inventory_control:InventoryControlBase = $MarginContainer/HBoxContainer/PlayerInventoryContainer/TabContainer/EQUIPMENT

func _ready():
	EventBus.add_inventory_to_HUD.connect(_on_add_inventory_to_HUD)
	EventBus.remove_inventory_from_HUD.connect(_on_remove_inventory_from_HUD)
	EventBus.item_control_quick_transfer.connect(_on_item_control_quick_transfer)
	
func _on_add_inventory_to_HUD(inventory_control:InventoryControlBase):
	Helpers.force_parent(inventory_control,world_inventories_container)
	if inventory_control is WorldInventory:
		inventory_control.player = player
	
func _on_remove_inventory_from_HUD(inventory_control:InventoryControlBase, new_parent:Node):
	Helpers.force_parent(inventory_control,new_parent)

func _on_item_control_quick_transfer(item_control:ItemControl):
	var item_instance:ItemInstance = InventoryManager.get_item(item_control.item_instance_id)
	if item_instance:
		if item_instance.current_inventory_id != player_inventory_id:
			EventBus.pickup_item.emit(item_instance, player_inventory_id)
		else:
			var world_inventory_control:InventoryControlBase = world_inventories_container.get_child(0)
			if world_inventory_control:
				EventBus.pickup_item.emit(item_instance, world_inventory_control.inventory_id)
