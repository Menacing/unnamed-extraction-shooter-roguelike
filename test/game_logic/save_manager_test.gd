# GdUnit generated TestSuite
class_name SaveManagerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_logic/save_manager.gd'

func before():
	await LevelManager.load_level_async("res://levels/biomes/science/easy/maps/lab_1.tscn", true)

func test_save_game() -> void:
	
	var num_item_3ds:int = ItemAccess.item_3ds.size()
	var num_item_instances:int = ItemAccess.item_instances.size()
	var num_item_controls:int = ItemAccess.item_controls.size()
	
	#equip an AK
	var player:Player = get_tree().get_nodes_in_group("players")[0]
	var start_player_inventory_id:int = player.player_inventory_id
	var first_instance:ItemInstance
	for key in ItemAccess.item_instances:
		first_instance = ItemAccess.item_instances[key]
		if first_instance.get_item_type_id() == "pm-52":
			break
	EventBus.pickup_item.emit(first_instance, player.player_inventory_id)
	var gun_instance_id:int = first_instance.item_instance_id



	#save data test
	SaveManager.save_game("integrated_save_test")
	var test_save_filename:String = "user://integrated_save_test.tres"
	
	#load game
	SaveManager.load_game(test_save_filename)
	await EventBus.game_loaded
	
	assert_int(ItemAccess.item_3ds.size()).is_equal(num_item_3ds)
	assert_int(ItemAccess.item_controls.size()).is_equal(num_item_controls)
	assert_int(ItemAccess.item_instances.size()).is_equal(num_item_instances)
	
	var loaded_player:Player = get_tree().get_nodes_in_group("players")[0]
	assert_int(loaded_player.player_inventory_id).is_equal(start_player_inventory_id)
	assert_object(loaded_player.equipped_gun).is_not_null()
	assert_int(loaded_player.equipped_gun.item_instance_id).is_equal(gun_instance_id)
	
