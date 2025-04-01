@tool
extends Node

const LOOT_SPAWN_DICTIONARY:LootSpawnDictionary = preload("res://game_logic/loot_spawn_dictionary.tres")
var remapped_loot_spawn_dictionary:Dictionary = {}

var _current_shuffle_bags:Dictionary = {}
var _model_shuffle_bags:Dictionary = {}

func _ready() -> void:
	for lsdk in LOOT_SPAWN_DICTIONARY.loot_spawn_dictionary:
		var loot_spawn_mapping := LOOT_SPAWN_DICTIONARY.loot_spawn_dictionary[lsdk]
		remapped_loot_spawn_dictionary[_map_loot_spawn_key_to_string(key)] = loot_spawn_mapping
		var model_shuffle_bag:Array[LootSpawnInformation] = []
		var current_shuffle_bag:Array[LootSpawnInformation] = []
		#generate shufflebags
		for i in range(loot_spawn_mapping.spawn_weights.size()):
			var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
			for j in range(weight.weight):
				model_shuffle_bag.append(weight.loot.duplicate())

		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[lsdk] = current_shuffle_bag
		_model_shuffle_bags[lsdk] = model_shuffle_bag

func _map_loot_spawn_key_to_string(lsk:LootSpawnKey) -> String:
	return str(lsk.loot_table) + "-" + str(lsk.tier)

func get_loot_spawn_mapping(lsk:LootSpawnKey):
	return remapped_loot_spawn_dictionary[_map_loot_spawn_key_to_string(lsk)]

func get_spawn_info(lsk:LootSpawnKey) -> LootSpawnInformation:
	var current_shuffle_bag = _current_shuffle_bags[lsk]
	var model_shuffle_bag = _model_shuffle_bags[lsk]
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[lsk] = current_shuffle_bag
	
	return current_shuffle_bag.pop_front()
