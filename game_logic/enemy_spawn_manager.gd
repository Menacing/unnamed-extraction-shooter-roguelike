@tool
extends Node

const ENEMY_SPAWN_DICTIONARY := preload("res://game_logic/enemy_spawn_dictionary.tres")
var remapped_enemy_spawn_dictionary:Dictionary = {}

func _ready():
	for key in ENEMY_SPAWN_DICTIONARY.enemy_spawn_dictionary:
		remapped_enemy_spawn_dictionary[_map_enemy_spawn_key_to_string(key)] = ENEMY_SPAWN_DICTIONARY.enemy_spawn_dictionary[key]
	
func _map_enemy_spawn_key_to_string(esk) -> String:
	return str(esk.faction) + "-" + str(esk.tier)

func get_enemy_spawn_mapping(esk:EnemySpawnKey):
	return remapped_enemy_spawn_dictionary[_map_enemy_spawn_key_to_string(esk)]

func get_difficulty_enemy_factor() -> float:
	match HideoutManager.selected_difficulty:
		GameplayEnums.GameDifficulty.EASY:
			return 1.0
		GameplayEnums.GameDifficulty.MEDIUM:
			return 1.5
		GameplayEnums.GameDifficulty.HARD:
			return 2.0
		_:
			return 1.0

func get_run_enemy_tier_bonus() -> int:
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
