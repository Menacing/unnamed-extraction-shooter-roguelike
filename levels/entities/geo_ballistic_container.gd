@tool
class_name GeoBallisticContainer
extends GeoBallisticSolid

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@export var biome_index:int
@export var tier_index:int
@export var min_spawned:int
@export var max_spawned:int
@export var container_size:int
@export var chance_active:float = 1.0

signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData = InventoryData.new()

func use(player:Player) -> void:
	toggle_inventory.emit(self)

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
	if 'chance_active' in func_godot_properties:
		chance_active = float(func_godot_properties['chance_active'])

	inventory_data = InventoryData.new()
	add_to_group("external_inventory", true)

		
var model_shuffle_bag:Array[LootSpawnInformation] = []
var current_shuffle_bag:Array[LootSpawnInformation] = []

func _ready():
	if Engine.is_editor_hint():
		return
	#do ballistic solid stuff
	super()
	#setup inventory linkages
	inventory_data.set_inventory_size(container_size)
	Helpers.apply_material_overlay_to_children(self, item_highlight_m)
	EventBus.populate_level.connect(_on_populate_level)
	EventBus.game_saving.connect(_on_game_saving)

func _on_game_saving(save_file:SaveFile):
	var save_data:LevelEntitySaveData = LevelEntitySaveData.new()
	save_data.node_path = self.get_path()
	save_file.level_entity_save_data.append(save_data)
	pass

func _on_load_game(save_data:LevelEntitySaveData):
	pass
	#inventory_id = save_data.additional_data["inventory_id"]
	#world_inventory_control.inventory_id = inventory_id

func _on_populate_level():
	
	var loot_spawn_mapping:LootSpawnMapping = LootSpawnManager.get_loot_spawn_mapping(biome_index,tier_index)
	
	randomize()
	#var active_roll:float = randf()
	#if active_roll > chance_active:
		#return
	
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
	if inventory_data:
		for i in range(number_to_spawn):
			var lsi:LootSpawnInformation = get_spawn_info()
			var item_info:ItemInformation = lsi.item_information
			
			var slot_data:SlotData = SlotData.instantiate_from_item_information(item_info)
			
			inventory_data.pick_up_slot_data(slot_data)

func get_spawn_info() -> LootSpawnInformation:
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()
