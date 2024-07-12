extends GdUnitTestSuite

var player_scene:PackedScene = load("res://game_objects/player/player.tscn")
var player:Player
var loaded_player:Player
var test_save_filename:String = "user://test_player_values_save_and_load_correctly.tres"



func before():
	player = player_scene.instantiate()
	self.add_child(player)
	loaded_player = player_scene.instantiate()
	self.add_child(loaded_player)

func test_values_save_and_load_correctly() -> void:
	var new_save_file = SaveFile.new()
	new_save_file.game_version = ProjectSettings.get_setting("application/config/version")
	new_save_file.level_scene_path = "TEST_LEVEL_SCENE_PATH"
	
	player.global_transform = Transform3D(Vector3.LEFT,Vector3.DOWN, Vector3.FORWARD, Vector3(2,4,8))
	
	#set different healths
	for key in player.health_component.health_locs:
		var loc:HealthLocation = player.health_component.health_locs[key]
		if loc.location == HealthLocation.HEALTH_LOCATION.LEGS:
			loc.current_health = 51
		elif loc.location == HealthLocation.HEALTH_LOCATION.ARMS:
			loc.current_health = 23
		elif loc.location == HealthLocation.HEALTH_LOCATION.MAIN:
			loc.current_health = 98
	
	var player_health_component:HealthComponent = player.health_component
	var loaded_player_health_component:HealthComponent = loaded_player.health_component
	
	#set ammo
	player.ammo_component.add_ammo("Fast Intermediate Cartdridge","Full Metal Jacket", 45)
	
	#save player data test
	player._on_game_saving(new_save_file)
	
	ResourceSaver.save(new_save_file,test_save_filename )
	
	var loaded_game:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	#check the file looks okay
	assert_str(loaded_game.game_version).is_equal(new_save_file.game_version)
	assert_str(loaded_game.level_scene_path).is_equal(new_save_file.level_scene_path)
	assert_bool(loaded_game.save_data.size() == new_save_file.save_data.size())
	assert_object(loaded_game.save_data[0].global_transform).is_equal(new_save_file.save_data[0].global_transform)
	
	var health_information = loaded_game.save_data[0].additional_data["health_info"]
	assert_object(health_information).is_not_null()
	
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.LEGS].current_health).is_equal_approx(51, 0.1)
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.ARMS].current_health).is_equal_approx(23, 0.1)
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.MAIN].current_health).is_equal_approx(98, 0.1)
	assert_int(loaded_game.save_data[0].additional_data["ammo_map"]["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount).is_equal(45)

	#check we don't have weird cross talk before loading the save into the player
	assert_object(loaded_player.global_transform).is_not_equal(player.global_transform)
	assert_float(loaded_player.health_component.main_loc.current_health).is_not_equal(player.health_component.main_loc.current_health)
	assert_int(loaded_player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount).is_not_equal(player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount)

func after():
	if player:
		player.queue_free()
