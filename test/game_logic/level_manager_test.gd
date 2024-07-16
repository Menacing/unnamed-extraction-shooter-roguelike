# GdUnit generated TestSuite
class_name LevelManagerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_logic/level_manager.gd'

var test_level_path:String = "res://test/game_logic/test_level.tscn"
var test_level_scene:PackedScene = load("res://test/game_logic/test_level.tscn")

func test_load_level_async() -> void:
	LevelManager.load_level_async(test_level_path, true)
	await EventBus.level_loaded
	
	LevelManager.clear_level()
