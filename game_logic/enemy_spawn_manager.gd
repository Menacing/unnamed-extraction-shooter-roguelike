@tool
extends Node

var _biome_index_mapping:Array[String] = ["science"]
##Keep this order in sync wit the FGD file res://levels/entities/area_enemy_spawn.tres
var _tier_index_mapping:Array[String] = ["easy","medium","hard"]

@onready var spawn_dictionary:Dictionary = {
	#biome type
	"science" = {
		#difficulty
		"easy" = load("res://levels/biomes/easi/0/enemy_spawns/easi_easy_enemy_spawn_mapping.tres")
	}
	
}

func get_enemy_spawn_mapping(biome_index:int, tier_index:int) -> EnemySpawnMapping:
	var biome = _biome_index_mapping[biome_index]
	var tier = _tier_index_mapping[tier_index]
	
	return spawn_dictionary[biome][tier]
