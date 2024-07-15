# GdUnit generated TestSuite
class_name SaveManagerSimpleTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_logic/save_manager.gd'

func before_test():
	InventoryManager._clear_inventories()
	ItemAccess._clear_items()
	LevelManager.clear_level()
	await LevelManager.load_level_async("res://test/game_logic/test_level.tscn", true)

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
	assert_int(gun_instance_id).is_not_equal(0)
	assert_int(start_player_inventory_id).is_not_equal(0)
	
	var starting_player_inventory:Inventory = InventoryAccess.get_inventory(start_player_inventory_id)
	var starting_player_gun_slot_1:EquipmentSlotType = Inventory.get_slot_by_name(starting_player_inventory,"GunSlot1")
	assert_int(starting_player_gun_slot_1.item_instance_id).is_equal(gun_instance_id)
	assert_object(player.equipped_gun).is_not_null()
	assert_int(player.equipped_gun.item_instance_id).is_equal(gun_instance_id)
	
	#save data test
	var saved_game_file:SaveFile = SaveManager.save_game("integrated_save_test")
	var test_save_filename:String = "user://integrated_save_test.tres"
	
	#load game
	var loaded_game_file:SaveFile = await SaveManager.load_game(test_save_filename)
	
	var loaded_gun_item_instance:ItemInstance = ItemAccess.get_item_instance(gun_instance_id)
	assert_object(loaded_gun_item_instance).is_not_null()
	var saved_inventory:Inventory
	var loaded_inventory:Inventory
	
	for inv:Inventory in saved_game_file.inventories:
		if inv.inventory_id == start_player_inventory_id:
			saved_inventory = inv
			
	for inv:Inventory in loaded_game_file.inventories:
		if inv.inventory_id == start_player_inventory_id:
			loaded_inventory = inv
	
	assert_object(saved_inventory).is_not_null()
	var saved_slot = Inventory.get_slot_by_name(saved_inventory,"GunSlot1")
	assert_int(saved_slot.item_instance_id).is_equal(gun_instance_id)
	
	assert_object(loaded_inventory).is_not_null()
	var loaded_slot = Inventory.get_slot_by_name(saved_inventory,"GunSlot1")
	assert_int(loaded_slot.item_instance_id).is_equal(gun_instance_id)
	
	assert_int(ItemAccess.item_3ds.size()).is_equal(num_item_3ds)
	assert_int(ItemAccess.item_controls.size()).is_equal(num_item_controls)
	assert_int(ItemAccess.item_instances.size()).is_equal(num_item_instances)
	
	var loaded_player:Player = get_tree().get_nodes_in_group("players")[0]
	assert_int(loaded_player.player_inventory_id).is_equal(start_player_inventory_id)
	var loaded_player_inventory:Inventory = InventoryAccess.get_inventory(loaded_player.player_inventory_id)
	var loaded_player_gun_slot_1:EquipmentSlotType = Inventory.get_slot_by_name(loaded_player_inventory,"GunSlot1")
	assert_int(loaded_player_gun_slot_1.item_instance_id).is_equal(gun_instance_id)
	assert_object(loaded_player.equipped_gun).is_not_null()
	assert_int(loaded_player.equipped_gun.item_instance_id).is_equal(gun_instance_id)
	
func after_test():
	InventoryManager._clear_inventories()
	ItemAccess._clear_items()
	LevelManager.clear_level()
