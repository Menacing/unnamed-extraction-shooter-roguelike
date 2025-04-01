@tool
extends Node

const ENEMY_SPAWN_DICTIONARY := preload("res://game_logic/enemy_spawn_dictionary.tres")
var remapped_enemy_spawn_dictionary:Dictionary = {}

func _ready():
	for key in ENEMY_SPAWN_DICTIONARY.enemy_spawn_dictionary:
		remapped_enemy_spawn_dictionary[_map_enemy_spawn_key_to_string(key)] = ENEMY_SPAWN_DICTIONARY.enemy_spawn_dictionary[key]
	
func _map_enemy_spawn_key_to_string(esk:EnemySpawnKey) -> String:
	return str(esk.faction) + "-" + str(esk.tier)

func get_enemy_spawn_mapping(esk:EnemySpawnKey):
	return remapped_enemy_spawn_dictionary[_map_enemy_spawn_key_to_string(esk)]
