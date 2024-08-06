@tool
extends Node

var _biome_index_mapping:Array[String] = ["science"]
##Keep this order in sync wit the FGD file res://levels/entities/area_loot_spawn.tres
var _tier_index_mapping:Array[String] = ["easy","medium","hard"]

@onready var spawn_dictionary:Dictionary = {
	#biome type
	"science" = {
		#difficulty
		"easy" = load("res://levels/biomes/easi/0/loot_spawns/easi_easy_loot_spawn_mapping.tres")
	}
	
}

func get_loot_spawn_mapping(biome_index:int, tier_index:int) -> LootSpawnMapping:
	var biome = _biome_index_mapping[biome_index]
	var tier = _tier_index_mapping[tier_index]
	
	return spawn_dictionary[biome][tier]
