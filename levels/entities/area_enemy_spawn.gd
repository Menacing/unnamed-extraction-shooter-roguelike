@tool
class_name AreaEnemySpawn
extends Area3D

@export var properties: Dictionary :
	get:
		return properties
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

@export var biome_index:int
@export var tier_index:int
@export var min_spawned:int
@export var max_spawned:int

func update_properties():
	if 'biome' in properties:
		biome_index = int(properties['biome'])	
	if 'tier' in properties:
		tier_index = int(properties['tier'])
	if 'min_spawned' in properties:
		min_spawned = int(properties['min_spawned'])
	if 'max_spawned' in properties:
		max_spawned = int(properties['max_spawned'])

var model_shuffle_bag:Array[EnemySpawnInformation] = []
var current_shuffle_bag:Array[EnemySpawnInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy_spawn_area")
	
	var enemy_spawn_mapping:EnemySpawnMapping = EnemySpawnManager.get_enemy_spawn_mapping(biome_index,tier_index)
	
	randomize()
	var number_to_spawn = randi_range(min_spawned,max_spawned)
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
				get_parent().add_child.call_deferred(scene)
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