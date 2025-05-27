@tool
extends Node



var _current_shuffle_bags:Dictionary = {}
var _model_shuffle_bags:Dictionary = {}

func _ready() -> void:
	for item_info in ItemMappingRepository.get_all_item_information():
		#generate shufflebags
		for i in range(loot_spawn_mapping.spawn_weights.size()):
			var weight:LootSpawnWeight = loot_spawn_mapping.spawn_weights[i]
			for j in range(weight.weight):
				model_shuffle_bag.append(weight.loot.duplicate())

		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[_map_loot_spawn_key_to_string(lsdk)] = current_shuffle_bag
		_model_shuffle_bags[_map_loot_spawn_key_to_string(lsdk)] = model_shuffle_bag

func _map_loot_spawn_key_to_string(lsk) -> String:
	return str(lsk.loot_table) + "-" + str(lsk.tier)

func get_loot_spawn_mapping(lsk:LootSpawnKey):
	return remapped_loot_spawn_dictionary[_map_loot_spawn_key_to_string(lsk)]

func get_spawn_info(lsk:LootSpawnKey) -> LootSpawnInformation:
	var current_shuffle_bag = _current_shuffle_bags[_map_loot_spawn_key_to_string(lsk)]
	var model_shuffle_bag = _model_shuffle_bags[_map_loot_spawn_key_to_string(lsk)]
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[lsk] = current_shuffle_bag
	
	return current_shuffle_bag.pop_front()

func get_difficulty_loot_factor() -> float:
	match HideoutManager.selected_difficulty:
		GameplayEnums.GameDifficulty.EASY:
			return 1.0
		GameplayEnums.GameDifficulty.MEDIUM:
			return 0.75
		GameplayEnums.GameDifficulty.HARD:
			return 0.5
		_:
			return 1.0

func get_run_loot_tier_bonus() -> int:
	var current_extracts:float = float(HideoutManager.current_map_number)
	var percent_complete:float = 0.0
	match HideoutManager.selected_run_length:
			GameplayEnums.GameLength.SHORT:
				percent_complete = current_extracts/3.0
			GameplayEnums.GameLength.MEDIUM:
				percent_complete = current_extracts/5.0
			GameplayEnums.GameLength.LONG:
				percent_complete = current_extracts/7.0
			_:
				return 0
	if percent_complete >= 0.65:
		return 2
	elif percent_complete >= 0.32:
		return 1
	else:
		return 0
