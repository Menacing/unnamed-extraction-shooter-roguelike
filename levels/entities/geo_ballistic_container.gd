@tool
class_name GeoBallisticContainer
extends GeoBallisticSolid

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@export var world_inventory_control_scene:PackedScene = preload("res://ui/inventory/world_inventory.tscn")
@export var biome_index:int
@export var tier_index:int
@export var min_spawned:int
@export var max_spawned:int
var world_inventory_control:WorldInventory
@export var container_size:int
var inventory_id:int

func _func_godot_apply_properties(entity_properties: Dictionary):
	super(entity_properties)
	if 'container_size' in func_godot_properties:
		container_size = int(func_godot_properties['container_size'])
	if 'biome' in func_godot_properties:
		biome_index = int(func_godot_properties['biome'])	
	if 'tier' in func_godot_properties:
		tier_index = int(func_godot_properties['tier'])
	if 'min_spawned' in func_godot_properties:
		min_spawned = int(func_godot_properties['min_spawned'])
	if 'max_spawned' in func_godot_properties:
		max_spawned = int(func_godot_properties['max_spawned'])

var model_shuffle_bag:Array[LootSpawnInformation] = []
var current_shuffle_bag:Array[LootSpawnInformation] = []

func _ready():
	if Engine.is_editor_hint():
		return
	#do ballistic solid stuff
	super()
	#instantiate inventory control
	world_inventory_control = world_inventory_control_scene.instantiate()
	self.add_child(world_inventory_control)
	
	#setup inventory linkages
	world_inventory_control.container_size = container_size
	inventory_id = world_inventory_control.inventory_id
	call_deferred("spawn_loot")
	EventBus.item_picked_up.connect(_on_item_picked_up)
	Helpers.apply_material_overlay_to_children(self, item_highlight_m)

func spawn_loot():
	add_to_group("loot_container")
	
	var loot_spawn_mapping:LootSpawnMapping = LootSpawnManager.get_loot_spawn_mapping(biome_index,tier_index)
	
	randomize()
	var number_to_spawn = randi_range(min_spawned,max_spawned)
	var aabb = Helpers.get_aabb_of_node(self)
	var x_size = aabb.size.x
	var z_size = aabb.size.z
	
	var spawned_locations:Array[Vector3] = []
	var spawned_test_radii:Array[float] = []
	
	#generate shufflebags
	for i in range(loot_spawn_mapping.spawn_weights.size()):
		var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
		for j in range(weight.weight):
			model_shuffle_bag.append(weight.loot.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
	if InventoryManager.inventory_exists(inventory_id):
		for i in range(number_to_spawn):
			var lsi:LootSpawnInformation = get_spawn_info()
			var item_info:ItemInformation = lsi.item_information
			var item_instance = ItemInstance.new(item_info)
			item_instance.spawn_item()
			if item_info.max_stacks > 0:
				var stack:int = randi_range(lsi.min_stack, lsi.max_stack)
				item_instance.stacks = stack
			EventBus.pickup_item.emit(item_instance, inventory_id)



func get_spawn_info() -> LootSpawnInformation:
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


func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == inventory_id:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_3d:Item3D = instance_from_id(item_instance.id_3d)
		Helpers.force_parent(item_3d,self)
		item_3d.picked_up()
		item_3d.visible = false


