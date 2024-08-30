extends Node3D
class_name LootFiestaComponent

@export var tier:LootSpawnManager.TIER
@export var biome:LootSpawnManager.BIOME
@export var distribution:GameplayEnums.StackRandomMethod
@export var min_to_spawn:int = 0
@export var max_to_spawn:int = 1
##Only required if using Normal distribution
@export var mean_to_spawn:int = 1

func fiesta():
	#Get mapping
	var loot_spawn_mapping:LootSpawnMapping = LootSpawnManager.get_loot_spawn_mapping(biome,tier)
	
	#Generate number to spawn
	var number_to_spawn:int
	if distribution == GameplayEnums.StackRandomMethod.RANDOM:
		number_to_spawn = randi_range(min_to_spawn, min_to_spawn)
	elif distribution == GameplayEnums.StackRandomMethod.NORMAL:
		number_to_spawn = Helpers.get_normalized_random_stack_count(min_to_spawn, mean_to_spawn, max_to_spawn)
	
	#generate shufflebags
	var model_shuffle_bag:Array[LootSpawnInformation] = []
	var current_shuffle_bag:Array[LootSpawnInformation] = []
	for i in range(loot_spawn_mapping.spawn_weights.size()):
		var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
		for j in range(weight.weight):
			model_shuffle_bag.append(weight.loot.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
	
	
	pass
