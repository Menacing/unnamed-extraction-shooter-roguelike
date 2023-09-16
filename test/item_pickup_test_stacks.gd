extends Control

@onready var player_inv_control = $PlayerInventory
@onready var player_inv_id:int = player_inv_control._inventory.get_instance_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_test_item()
	add_test_item()
	add_test_item()
	add_test_item()
	add_test_item()
	add_test_item()
	pass # Replace with function body.

func add_test_item():
	var cell_size = 32
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 2
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.MATERIAL
	item_info.display_name = "Test Item"
	item_info.show_name = true
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/items/materials/polymer_pile/polymer_pile_icon.png")
	item_info.icon_r = load("res://Scenes/items/materials/polymer_pile/polymer_pile_icon.png")
	item_info.show_name = false
	item_info.context_menu_items = [load("res://ui/inventory/drop_item_context_item.tres")]
	var item:ItemInstance = ItemInstance.new(item_info)
	item._item_info = item_info
	item.stacks = 1
	
	var item_control:ItemControl = load("res://ui/inventory/item_control.tscn").instantiate()
	item_control.size.x = item_info.row_span * cell_size
	item_control.size.y = item_info.column_span * cell_size
	item_control.item_instance_id = item.get_instance_id()
	
	item.id_2d = item_control.get_instance_id()
	
	self.add_child(item_control)
	EventBus.pickup_item.emit(item,player_inv_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



