extends GdUnitTestSuite

var player:Player
var test_save_filename:String = "user://test_player_values_save_and_load_correctly.tres"

func before():
	player = load("res://game_objects/player/player.tscn").instantiate()
	self.add_child(player)

func test_values_save_and_load_correctly() -> void:
	var new_save_file = SaveFile.new()
	new_save_file.game_version = ProjectSettings.get_setting("application/config/version")
	new_save_file.level_scene_path = "TEST_LEVEL_SCENE_PATH"
	
	#save player data test
	player._on_game_saving(new_save_file)
	
	ResourceSaver.save(new_save_file,test_save_filename )
	
	var loaded_game:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	
	assert_str(loaded_game.game_version).is_equal(new_save_file.game_version)
	assert_str(loaded_game.level_scene_path).is_equal(new_save_file.level_scene_path)
	assert_bool(loaded_game.save_data.size() == new_save_file.save_data.size())
	assert_object(loaded_game.save_data[0].global_transform).is_equal(new_save_file.save_data[0].global_transform)


func after():
	if player:
		player.queue_free()
