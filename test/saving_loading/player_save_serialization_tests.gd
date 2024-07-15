extends GdUnitTestSuite

var player_scene:PackedScene = load("res://game_objects/player/player.tscn")
var player:Player
var loaded_player:Player
var test_save_filename:String = "user://test_player_values_save_and_load_correctly.tres"
var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
var item_info:ItemInformation = load("res://game_objects/items/materials/polymer_pile/polymer_pile_inventory_info.tres")

func before_test():
	InventoryManager._clear_inventories()
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
	assert_bool(loaded_game.top_level_entity_save_data.size() == new_save_file.top_level_entity_save_data.size())
	assert_object(loaded_game.top_level_entity_save_data[0].global_transform).is_equal(new_save_file.top_level_entity_save_data[0].global_transform)
	
	var health_information = loaded_game.top_level_entity_save_data[0].additional_data["health_info"]
	assert_object(health_information).is_not_null()
	
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.LEGS].current_health).is_equal_approx(51, 0.1)
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.ARMS].current_health).is_equal_approx(23, 0.1)
	assert_float(health_information[HealthLocation.HEALTH_LOCATION.MAIN].current_health).is_equal_approx(98, 0.1)
	assert_int(loaded_game.top_level_entity_save_data[0].additional_data["ammo_map"]["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount).is_equal(45)

	#check we don't have weird cross talk before loading the save into the player
	assert_object(loaded_player.global_transform).is_not_equal(player.global_transform)
	assert_float(loaded_player.health_component.main_loc.current_health).is_not_equal(player.health_component.main_loc.current_health)
	assert_int(loaded_player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount).is_not_equal(player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount)

	#load the save data into the player
	loaded_player._on_load_game(loaded_game.top_level_entity_save_data[0])
	
	#things should be the same again
	assert_object(loaded_player.global_transform).is_equal(player.global_transform)
	assert_float(loaded_player.health_component.main_loc.current_health).is_equal(player.health_component.main_loc.current_health)
	assert_int(loaded_player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount).is_equal(player.ammo_component._ammo_map["Fast Intermediate Cartdridge"]["Full Metal Jacket"].current_amount)

func test_inventory_saving_and_loading() -> void:
	#saving
	#arrange
	var new_save_file = SaveFile.new()
	var initial_player_inventory_id:int = player.player_inventory_id
	
	#act
	EventBus.populate_level.emit()
	EventBus.players_spawned.emit()
	var populated_player_inventory_id:int = player.player_inventory_id
	player._on_game_saving(new_save_file)
	
	#assert
	assert_int(populated_player_inventory_id).is_not_equal(initial_player_inventory_id)
	var player_save_data:TopLevelEntitySaveData = new_save_file.top_level_entity_save_data[0]
	var saved_player_inventory_id = player_save_data.additional_data["player_inventory_id"]
	assert_int(saved_player_inventory_id).is_equal(populated_player_inventory_id)
	
	#loading
	#arrange
	var loaded_player_data:TopLevelEntitySaveData = player_save_data
	var initial_loaded_player_inventory_id:int = loaded_player.player_inventory_id
	var loaded_inventory:Inventory = test_inventory.duplicate(true)
	loaded_inventory.setup()
	var item_instance:ItemInstance = ItemInstance.new(item_info)
	var test_item_instance_id:int = item_instance.item_instance_id
	loaded_inventory.grid_slots[0][0] = test_item_instance_id
	loaded_player_data.additional_data["player_inventory_id"] = loaded_inventory.inventory_id
	
	#act
	item_instance.spawn_item()
	loaded_player._on_load_game(loaded_player_data)
	InventoryManager._restore_inventories.call_deferred()
	await InventoryManager.inventories_restored
	#assert
	assert_int(test_item_instance_id).is_not_equal(0)
	assert_int(loaded_player.player_inventory_id).is_equal(loaded_inventory.inventory_id)
	assert_int(loaded_player.player_inventory_id).is_not_equal(initial_loaded_player_inventory_id)
	
	var loaded_player_inventory:Inventory = InventoryAccess.get_inventory(loaded_player.player_inventory_id)
	var loaded_player_inventory_control:InventoryControlBase = loaded_player.get_node("PlayerInventories/MarginContainer/HBoxContainer/PlayerInventoryContainer/TabContainer/EQUIPMENT")
	assert_object(loaded_player_inventory).is_not_null()
	#inventory should have a polymer pile at 0,0
	assert_int(loaded_player_inventory.grid_slots[0][0]).is_equal(item_instance.item_instance_id)
	#control should have a control under the first panel
	var inv_grid = loaded_player_inventory_control.get_inventory_grid()
	assert_object(inv_grid).is_not_null()
	var first_cell = inv_grid.get_child(0)
	assert_object(first_cell).is_not_null()
	assert_int(first_cell.get_child_count()).is_equal(1)

func test_grid_and_slots_save_and_load() -> void:
	#arrange
	var new_save_file = SaveFile.new()
	var initial_player_inventory_id:int = player.player_inventory_id
	EventBus.populate_level.emit()
	EventBus.players_spawned.emit()
	var setup_player_inventory_id:int = player.player_inventory_id
	var player_inventory:Inventory = InventoryAccess.get_inventory(player.player_inventory_id)
	var item_id_1 = randi()
	var item_id_2 = randi()
	
	#act
	player_inventory.grid_slots[0][0] = item_id_1
	player_inventory.equipment_slots[0].item_instance_id = item_id_2
	player._on_game_saving(new_save_file)
	InventoryManager._on_game_saving(new_save_file)
	ResourceSaver.save(new_save_file,test_save_filename )
	
	var loaded_save_file:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	
	var saved_inventory:Inventory
	var loaded_inventory:Inventory
	
	assert_int(setup_player_inventory_id).is_not_equal(initial_player_inventory_id)
	assert_int(setup_player_inventory_id).is_not_equal(0)
	
	for inv:Inventory in new_save_file.inventories:
		if inv.inventory_id == setup_player_inventory_id:
			saved_inventory = inv
			
	for inv:Inventory in loaded_save_file.inventories:
		if inv.inventory_id == setup_player_inventory_id:
			loaded_inventory = inv
	
	assert_int(new_save_file.top_level_entity_save_data[0].additional_data["player_inventory_id"]).is_equal(setup_player_inventory_id)
	assert_object(saved_inventory).is_not_null()

	assert_int(saved_inventory.grid_slots[0][0]).is_equal(item_id_1)
	assert_int(saved_inventory.equipment_slots[0].item_instance_id).is_equal(item_id_2)
	
	assert_object(loaded_inventory).is_not_null()
	assert_int(loaded_inventory.grid_slots[0][0]).is_equal(item_id_1)
	assert_int(loaded_inventory.equipment_slots[0].item_instance_id).is_equal(item_id_2)

func after_test():
	if player:
		player.queue_free()
	if loaded_player:
		loaded_player.queue_free()
	InventoryManager._clear_inventories()
