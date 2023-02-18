extends StaticBody3D

#@onready var container_bag:InventoryBag = $CanvasLayer/Panel/InventoryBag
@onready var inv_menu:CanvasLayer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	inv_menu.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func use(player:Player):
	inv_menu.visible = true
	player.toggle_inventory()
	Events.inventory_closed.connect(on_inv_closed)

func on_inv_closed(player:Player):
	inv_menu.visible = false
	Events.inventory_closed.disconnect(on_inv_closed)


func _on_inventory_bag_item_dropped(inv_container_event):
#	if inv_container_event.container != container_bag:
#		print("Different Bag")
#	elif inv_container_event.container == container_bag:
#		print("Same Bag")
	pass # Replace with function body.
