@tool
extends Node

var _current_shuffle_bags:Dictionary = {}
var _model_shuffle_bags:Dictionary = {}

func _ready() -> void:
	for item_info in ItemMappingRepository.get_all_item_information():
		#generate shufflebags
		var model_shuffle_bag:Array[String] = []
		var current_shuffle_bag:Array[String] = []
		for i in range(get_rarity_value(item_info.rarity)):
			model_shuffle_bag.append(item_info.item_type_id)

		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[_map_loot_spawn_key_to_string(item_info.loot_table, item_info.tier)] = current_shuffle_bag
		_model_shuffle_bags[_map_loot_spawn_key_to_string(item_info.loot_table, item_info.tier)] = model_shuffle_bag

func _map_loot_spawn_key_to_string(loot_table:GameplayEnums.LootTable, tier:GameplayEnums.Tier) -> String:
	return str(loot_table) + "-" + str(tier)

func get_spawn_info(loot_table:GameplayEnums.LootTable, tier:GameplayEnums.Tier) -> ItemInformation:
	var current_shuffle_bag = _current_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)]
	var model_shuffle_bag = _model_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)]
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)] = current_shuffle_bag
	
	return ItemMappingRepository.get_item_information(current_shuffle_bag.pop_front())

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

func get_rarity_value(rarity:GameplayEnums.Rarity) -> int:
	match rarity:
		GameplayEnums.Rarity.COMMON:
			return 5
		GameplayEnums.Rarity.UNCOMMON:
			return 4
		GameplayEnums.Rarity.RARE:
			return 3
		GameplayEnums.Rarity.EPIC:
			return 2
		GameplayEnums.Rarity.UNIQUE:
			return 1
		_:
			return 0

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
