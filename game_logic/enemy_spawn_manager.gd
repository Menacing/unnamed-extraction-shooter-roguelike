@tool
extends Node

const ENEMY_SPAWN_DICTIONARY := preload("res://game_logic/enemy_spawn_dictionary.tres")

func get_enemy_spawn_mapping(esk:EnemySpawnKey):
	return ENEMY_SPAWN_DICTIONARY.enemy_spawn_dictionary[esk]
