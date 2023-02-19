extends StaticBody3D

#@onready var container_bag:InventoryBag = $CanvasLayer/Panel/InventoryBag
@export var inv: PackedScene
@export var container_size:int
# Called when the node enters the scene tree for the first time.
func _ready():
	var inv_node = inv.instantiate()
	inv_node.container_size = container_size
	Events.create_inventory.emit(inv_node,self.name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func use(player:Player):
	player.toggle_inventory()
	Events.player_inventory_closed.connect(on_inv_closed)
	Events.open_inventory.emit(self.name)

func on_inv_closed(player:Player):
	Events.close_inventory.emit(self.name)
	Events.player_inventory_closed.disconnect(on_inv_closed)


func _on_inventory_bag_item_dropped(inv_container_event):
#	if inv_container_event.container != container_bag:
#		print("Different Bag")
#	elif inv_container_event.container == container_bag:
#		print("Same Bag")
	pass # Replace with function body.
