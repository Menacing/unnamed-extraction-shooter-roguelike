@tool
class_name AreaLootSpawn
extends Area3D

@export var biome_index:int
@export var tier_index:int
@export var min_spawned:int
@export var max_spawned:int
@export var chance_active:float = 1.0

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
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

var model_shuffle_bag:Array[LootSpawnInformation] = []
var current_shuffle_bag:Array[LootSpawnInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("loot_spawn_area")
	
	var loot_spawn_mapping:LootSpawnMapping = LootSpawnManager.get_loot_spawn_mapping(biome_index,tier_index)
	
	randomize()
	
	var active_roll:float = randf()
	if active_roll > chance_active:
		return
		
	var number_to_spawn = randi_range(min_spawned,max_spawned)
	var aabb = Helpers.get_aabb_of_node(self)
	var x_begin = aabb.position.x
	var x_end = aabb.end.x
	var z_begin = aabb.position.z
	var z_end = aabb.end.z
	
	var spawned_locations:Array[Vector3] = []
	var spawned_test_radii:Array[float] = []
	
	#generate shufflebags
	for i in range(loot_spawn_mapping.spawn_weights.size()):
		var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
		for j in range(weight.weight):
			model_shuffle_bag.append(weight.loot.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
	
	for i in range(number_to_spawn):
		var lsi:LootSpawnInformation = get_spawn_info()
		var item_info:ItemInformation = lsi.item_information
		var final_pos:Vector3
		var remaining_tries = 5
		while remaining_tries > 1:
			#generate random location
			var try_pos = Vector3(randf_range(x_begin,x_end),0,randf_range(z_begin,z_end))
			var loc_free = true
			for k in range(spawned_locations.size()):
				#check if location overlaps existing location
				if abs((spawned_locations[k] - try_pos).length()) < lsi.test_radius:
					loc_free = false
			#if clear, spawn scene
			if loc_free:
				var scene = item_info.item_3d_scene.instantiate()
				scene.set_as_top_level(true)		
				get_parent().add_child.call_deferred(scene)
				scene.set_global_position.call_deferred(try_pos + self.global_position)
				spawned_locations.append(try_pos)
				remaining_tries = 0
			else:
				remaining_tries -= 1


func get_spawn_info() -> LootSpawnInformation:
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()
