extends Node3D
class_name CorpseContainer

@export var inv_scene: PackedScene = load("res://ui/inventory/WorldInventory.tscn")
@export var container_size:int = 14
var inv_name:String

@export var loot_scenes:Array[PackedScene]
var loot_item_comps = []

func _ready():
	var inv_node:WorldInventory = inv_scene.instantiate()
	inv_node.container_size = container_size
	inv_name = str(inv_node.get_instance_id())
	Events.create_inventory.emit(inv_node,inv_name)
	
	for loot in loot_scenes:
		var loot1_node = loot.instantiate()
	#	inv_node.ready.connect(fill_container)
	#	await loot1_node.ready
		self.add_child(loot1_node)
		loot1_node.visible = false
		var loot1_item_comp = loot1_node.get_node("ItemComponent")
		loot1_item_comp.picked_up()
		loot_item_comps.append(loot1_item_comp)
	fill_container()
	

func fill_container():
	var inv_node = InventoryManager.get_inventory(inv_name)
	if inv_node:
		await inv_node.ready
		for comp in loot_item_comps:
			inv_node.pickup_item(comp)

func use(player:Player):
	player.toggle_inventory()
	Events.player_inventory_closed.connect(on_inv_closed)
	Events.open_inventory.emit(inv_name)

func on_inv_closed(player:Player):
	Events.close_inventory.emit(inv_name)
	Events.player_inventory_closed.disconnect(on_inv_closed)
