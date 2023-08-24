extends CollisionObject3D

@onready var world_inventory_control = $WorldInventory
var inventory_id:int
@export var container_size:int
@export var min_spawned:int
@export var max_spawned:int
@export var spawn_info:Array[LootInformation]

var model_shuffle_bag:Array[LootInformation] = []
var current_shuffle_bag:Array[LootInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	world_inventory_control.container_size = container_size
	inventory_id = world_inventory_control.inventory_id
	randomize()
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
			
	
	if InventoryManager.inventory_exists(inventory_id):
		for i in range(number_to_spawn):
			var info:LootInformation = get_spawn_info()
			var item_instance = ItemInstance.new(info.item_information)
			item_instance.spawn_item()
			if info.max_stack > 0:
				var stack:int = randi_range(info.min_stack, info.max_stack)
				item_instance.stacks = stack
			EventBus.pickup_item.emit(item_instance, inventory_id)

func get_spawn_info() -> LootInformation:
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()

func use(player:Player):
	if world_inventory_control.visible:
		player.close_inventory()
		EventBus.close_inventory.emit(inventory_id)
	else:
		player.open_inventory()
		EventBus.open_inventory.emit(inventory_id)

func on_inv_closed(player:Player):
	EventBus.close_inventory.emit(inventory_id)
	#EventBus.player_inventory_closed.disconnect(on_inv_closed)


