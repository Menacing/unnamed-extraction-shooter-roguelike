extends CanvasLayer

@export var player:Player
@onready var player_inventory_id:int:
	get:
		return player_inventory_control.inventory_id
	set(value):
		player_inventory_control.inventory_id = value
@onready var world_inventories_container:Container = $MarginContainer/HBoxContainer/WorldInventoryContainer
@onready var player_inventory_control:InventoryControlBase = $MarginContainer/HBoxContainer/PlayerInventoryContainer/TabContainer/EQUIPMENT

func _ready():
	EventBus.add_control_to_HUD.connect(_on_add_control_to_HUD)
	EventBus.remove_control_from_HUD.connect(_on_remove_control_from_HUD)
	EventBus.item_control_quick_transfer.connect(_on_item_control_quick_transfer)
	
func _on_add_control_to_HUD(control:Control):
	Helpers.force_parent(control,world_inventories_container)
	if control is WorldInventory:
		control.player = player
	
func _on_remove_control_from_HUD(control:Control, new_parent:Node):
	Helpers.force_parent(control,new_parent)

func _on_item_control_quick_transfer(item_control:ItemControl):
	var item_instance:ItemInstance = InventoryManager.get_item(item_control.item_instance_id)
	if item_instance:
		if item_instance.current_inventory_id != player_inventory_id:
			EventBus.pickup_item.emit(item_instance, player_inventory_id)
		else:
			var world_inventory_control:InventoryControlBase = world_inventories_container.get_child(0)
			if world_inventory_control:
				EventBus.pickup_item.emit(item_instance, world_inventory_control.inventory_id)
