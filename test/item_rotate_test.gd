extends Control

@onready var player_inv_control = $PlayerInventory
@onready var player_inv_id:int = player_inv_control._inventory.get_instance_id()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_test_item()
	add_test_item()
	add_test_item()
	pass # Replace with function body.

func add_test_item():
	var cell_size = 32
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	
	item._item_info = item_info
	item.stacks = 1
	
	var item_control:ItemControl = load("res://ui/inventory/item_control.tscn").instantiate()
	item_control.item_instance_id= item.get_instance_id()
	item_control.update_dimensions()
	
	item.id_2d = item_control.get_instance_id()
	
	self.add_child(item_control)
	EventBus.pickup_item.emit(item,player_inv_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



