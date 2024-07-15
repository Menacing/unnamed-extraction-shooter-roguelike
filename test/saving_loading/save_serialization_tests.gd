extends GdUnitTestSuite


func test_values_save_and_load_correctly() -> void:
	var new_save_file = SaveFile.new()
	new_save_file.game_version = ProjectSettings.get_setting("application/config/version")
	new_save_file.level_scene_path = "TEST_LEVEL_SCENE_PATH"
	var test_save_filename:String = "user://test_values_save_and_load_correctly.tres"
	
	#save data test
	var test_save_data:TopLevelEntitySaveData = TopLevelEntitySaveData.new()
	test_save_data.global_transform = Transform3D(Vector3.LEFT,Vector3.DOWN, Vector3.FORWARD, Vector3(2,4,8))
	test_save_data.scene_path = "SAVE_DATA_SCENE_PATH"
	new_save_file.top_level_entity_save_data.append(test_save_data)
	
	ResourceSaver.save(new_save_file,test_save_filename )
	
	var loaded_game:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	
	assert_str(loaded_game.game_version).is_equal(new_save_file.game_version)
	assert_str(loaded_game.level_scene_path).is_equal(new_save_file.level_scene_path)
	assert_bool(loaded_game.top_level_entity_save_data.size() == new_save_file.top_level_entity_save_data.size())
	assert_object(loaded_game.top_level_entity_save_data[0].global_transform).is_equal(new_save_file.top_level_entity_save_data[0].global_transform)

