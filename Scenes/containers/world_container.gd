extends CollisionObject3D

#@onready var container_bag:InventoryBag = $CanvasLayer/Panel/InventoryBag
@export var inv: PackedScene
var inv_name:String
@export var container_size:int
@export var min_spawned:int
@export var max_spawned:int
@export var spawn_info:Array[LootInformation]

var model_shuffle_bag:Array[LootInformation] = []
var current_shuffle_bag:Array[LootInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var inv_node = inv.instantiate()
	inv_node.container_size = container_size
	inv_name = str(inv_node.get_instance_id())
	Events.create_inventory.emit(inv_node,inv_name)
	randomize()
	await inv_node.ready
	call_deferred("spawn_loot")


func spawn_loot():
	var number_to_spawn = randi_range(min_spawned,max_spawned)
	
	#generate shufflebags
	for i in range(spawn_info.size()):
		var info = spawn_info[i]
		for j in range(info.spawn_weight):
			model_shuffle_bag.append(info.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
			
	var inv_inst = InventoryManager.get_inventory(inv_name)
	
#	for loot in loot_scenes:
#		var loot1_node = loot.instantiate()
#		self.add_child(loot1_node)
#		loot1_node.visible = false
#		var loot1_item_comp = loot1_node.get_node("ItemComponent")
#		loot1_item_comp.picked_up()
#		loot_item_comps.append(loot1_item_comp)
	
	if inv_inst:
		for i in range(number_to_spawn):
			var info = get_spawn_info()
			var scene = info.scene.instantiate()
			self.add_child(scene)
			scene.visible = false
			var ic = scene.get_node("ItemComponent") as ItemComponent
			ic.picked_up()
			
			if info.max_stack > 0:
				var stack:int = randi_range(info.min_stack, info.max_stack)
				ic.stack = stack
			inv_inst.pickup_item(ic)

func get_spawn_info():
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()

func use(player:Player):
	player.toggle_inventory()
	Events.player_inventory_closed.connect(on_inv_closed)
	Events.open_inventory.emit(inv_name)

func on_inv_closed(player:Player):
	Events.close_inventory.emit(inv_name)
	Events.player_inventory_closed.disconnect(on_inv_closed)


func _on_inventory_bag_item_dropped(inv_container_event):
#	if inv_container_event.container != container_bag:
#		print("Different Bag")
#	elif inv_container_event.container == container_bag:
#		print("Same Bag")
	pass # Replace with function body.