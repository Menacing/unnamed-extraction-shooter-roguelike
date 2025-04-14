@tool
class_name AreaEnemySpawn
extends Area3D

@export var faction:GameplayEnums.EnemyFaction
@export var tier:GameplayEnums.Tier
@export var min_spawned:int
@export var max_spawned:int
@export var chance_active:float = 1.0

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'faction' in func_godot_properties:
		faction = int(func_godot_properties['faction'])	
	if 'tier' in func_godot_properties:
		tier = int(func_godot_properties['tier'])
	if 'min_spawned' in func_godot_properties:
		min_spawned = int(func_godot_properties['min_spawned'])
	if 'max_spawned' in func_godot_properties:
		max_spawned = int(func_godot_properties['max_spawned'])
	if 'chance_active' in func_godot_properties:
		chance_active = float(func_godot_properties['chance_active'])

var model_shuffle_bag:Array[EnemySpawnInformation] = []
var current_shuffle_bag:Array[EnemySpawnInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy_spawn_area",true)
	add_to_group("has_on_populate_level_function",true)
		
func _on_populate_level():
	var esk:EnemySpawnKey = EnemySpawnKey.new()
	esk.faction = faction
	esk.tier = Helpers.clamp_int_to_enum(tier + EnemySpawnManager.get_run_enemy_tier_bonus(), GameplayEnums.Tier)
	var enemy_spawn_mapping:EnemySpawnMapping = EnemySpawnManager.get_enemy_spawn_mapping(esk)
	
	randomize()
	
	var active_roll:float = randf()
	if active_roll > chance_active:
		return
		
	var number_to_spawn = int(randi_range(min_spawned,max_spawned) * EnemySpawnManager.get_difficulty_enemy_factor())
	var aabb = Helpers.get_aabb_of_node(self)
	var x_size = aabb.size.x
	var z_size = aabb.size.z
	
	var spawned_locations:Array[Vector3] = []
	var spawned_test_radii:Array[float] = []
	
	#generate shufflebags
	for i in range(enemy_spawn_mapping.spawn_weights.size()):
		var weight:EnemySpawnWeight = enemy_spawn_mapping.spawn_weights[i]
		for j in range(weight.weight):
			model_shuffle_bag.append(weight.enemy.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
	
	for i in range(number_to_spawn):
		var info:EnemySpawnInformation = get_spawn_info()
		
		var final_pos:Vector3
		var remaining_tries = 5
		while remaining_tries > 1:
			#generate random location
			var try_pos = Vector3(randf_range(-x_size,x_size),0,randf_range(-z_size,z_size))
			var loc_free = true
			for k in range(spawned_locations.size()):
				#check if location overlaps existing location
				if abs((spawned_locations[k] - try_pos).length()) < info.test_radius:
					loc_free = false
			#if clear, spawn scene
			if loc_free:
				var scene = info.scene.instantiate()
				scene.set_as_top_level(true)		
				LevelManager.add_node_to_level.call_deferred(scene)
				scene.set_global_position.call_deferred(try_pos + self.global_position)
				spawned_locations.append(try_pos)
				remaining_tries = 0
			else:
				remaining_tries -= 1


func get_spawn_info() -> EnemySpawnInformation:
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()
