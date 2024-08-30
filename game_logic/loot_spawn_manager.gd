@tool
extends Node

enum BIOME {EASI, WODC, CENT, NEUTRAL}
var _biome_index_mapping:Array[String] = ["science"]
##Keep this order in sync wit the FGD file res://levels/entities/area_loot_spawn.tres
enum TIER {COMMON, UNCOMMON, RARE, EXPERIMENTAL, ALIEN}
var _tier_index_mapping:Array[String] = ["easy","medium","hard"]

##DEPRECATED
@onready var spawn_dictionary:Dictionary = {
	#biome type
	"science" = {
		#difficulty
		"easy" = load("res://levels/biomes/easi/0/loot_spawns/easi_easy_loot_spawn_mapping.tres")
	}
}

@onready var loot_spawn_mapping_mapping:Dictionary = {
	BIOME.EASI : {
		TIER.COMMON : load("res://levels/biomes/easi/0/loot_spawns/easi_easy_loot_spawn_mapping.tres")
	}
}

var _current_shuffle_bags:Dictionary = {}
var _model_shuffle_bags:Dictionary = {}

func _ready() -> void:
	
	#generate shufflebags
	for i in range(loot_spawn_mapping.spawn_weights.size()):
		var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
		for j in range(weight.weight):
			model_shuffle_bag.append(weight.loot.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()

func get_loot_spawn_mapping(biome_index:int, tier_index:int) -> LootSpawnMapping:
	var biome = _biome_index_mapping[biome_index]
	var tier = _tier_index_mapping[tier_index]
	
	return spawn_dictionary[biome][tier]

func get_spawn_info(biome:BIOME, tier:TIER) -> LootSpawnInformation:
	var current_shuffle_bag = _current_shuffle_bags[biome][tier]
	var model_shuffle_bag = _model_shuffle_bags[biome][tier]
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[biome][tier] = current_shuffle_bag
	
	return current_shuffle_bag.pop_front()
