@tool
class_name GeoBallisticContainer
extends GeoBallisticSolid

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@export var loot_table:GameplayEnums.LootTable
@export var tier:GameplayEnums.Tier
@export var rarity:GameplayEnums.Rarity
@export var max_spawned:int
@export var container_size:int

var number_spawned:int = 0

signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData = InventoryData.new()

func use(player:Player) -> void:
	toggle_inventory.emit(self)

func _func_godot_apply_properties(entity_properties: Dictionary):
	super(entity_properties)
	if 'container_size' in func_godot_properties:
		container_size = int(func_godot_properties['container_size'])
	if 'loot_table' in func_godot_properties:
		loot_table = int(func_godot_properties['loot_table'])	
	if 'tier' in func_godot_properties:
		tier = int(func_godot_properties['tier'])
	if 'rarity' in func_godot_properties:
		rarity = int(func_godot_properties['rarity'])
	if 'max_spawned' in func_godot_properties:
		max_spawned = int(func_godot_properties['max_spawned'])

	inventory_data = InventoryData.new()
	add_to_group("external_inventory", true)
	add_to_group("loot_spawn_container", true)
	


func _ready():
	if Engine.is_editor_hint():
		return
	#do ballistic solid stuff
	super()
	#setup inventory linkages
	inventory_data.set_inventory_size(container_size)
	Helpers.apply_material_overlay_to_children(self, item_highlight_m)
	EventBus.game_saving.connect(_on_game_saving)
	#add_to_group("has_on_populate_level_function",true)


func _on_game_saving(save_file:SaveFile):
	var save_data:LevelEntitySaveData = LevelEntitySaveData.new()
	save_data.node_path = self.get_path()
	save_data.additional_data["inventory_data"] = inventory_data
	save_file.level_entity_save_data.append(save_data)
	pass

func _on_load_game(save_data:LevelEntitySaveData):
	pass
	inventory_data = save_data.additional_data["inventory_data"]
#
#func _on_populate_level():
	#var lsk:LootSpawnKey = LootSpawnKey.new()
	#lsk.loot_table = loot_table
	#lsk.tier = Helpers.clamp_int_to_enum(tier + LootSpawnManager.get_run_loot_tier_bonus(), GameplayEnums.Tier)
	#var loot_spawn_mapping:LootSpawnMapping = LootSpawnManager.get_loot_spawn_mapping(lsk)
	#
	#randomize()
	##var active_roll:float = randf()
	##if active_roll > chance_active:
		##return
	#
	#var number_to_spawn = int(randi_range(min_spawned,max_spawned) * LootSpawnManager.get_difficulty_loot_factor())
	#var aabb = Helpers.get_aabb_of_node(self)
	#var x_size = aabb.size.x
	#var z_size = aabb.size.z
	#
	#var spawned_locations:Array[Vector3] = []
	#var spawned_test_radii:Array[float] = []
	#
	##generate shufflebags
	#for i in range(loot_spawn_mapping.spawn_weights.size()):
		#var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
		#for j in range(weight.weight):
			#model_shuffle_bag.append(weight.loot.duplicate())
	#
	#current_shuffle_bag = model_shuffle_bag.duplicate(true)
	#current_shuffle_bag.shuffle()
	#if inventory_data:
		#for i in range(number_to_spawn):
			#var lsi:LootSpawnInformation = get_spawn_info()
			#var item_info:ItemInformation = lsi.item_information
			#
			#var slot_data:SlotData = SlotData.instantiate_from_item_information(item_info)
			#
			#inventory_data.pick_up_slot_data(slot_data)
#
#func get_spawn_info() -> LootSpawnInformation:
	#if current_shuffle_bag.is_empty():
		#current_shuffle_bag = model_shuffle_bag.duplicate(true)
		#current_shuffle_bag.shuffle()
	#
	#return current_shuffle_bag.pop_front()
