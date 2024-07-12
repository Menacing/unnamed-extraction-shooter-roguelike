# GdUnit generated TestSuite
class_name InventoryManagerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_logic/inventory_manager.gd'

var test_level_path:String = "res://levels/biomes/science/easy/maps/lab_1.tscn"
@onready var player_scene:PackedScene = load("res://game_objects/player/player.tscn")
@onready var player:Player
@onready var test_inv:Inventory 
@onready var item_info:ItemInformation = load("res://game_objects/items/materials/polymer_pile/polymer_pile_inventory_info.tres")
@onready var item_inst:ItemInstance = ItemInstance.new(item_info)
func before():
	player = player_scene.instantiate()
	self.add_child(player)
	test_inv = InventoryAccess.get_inventory(player.player_inventory_id)
	item_inst.spawn_item()
	InventoryManager._on_pickup_item(item_inst, test_inv.inventory_id)

func test__on_game_saving() -> void:
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_int(ItemAccess.item_3ds.size()).is_equal(1)
	assert_int(ItemAccess.item_controls.size()).is_equal(1)
	assert_int(ItemAccess.item_instances.size()).is_equal(1)
	assert_int(InventoryAccess.inventories[test_inv.inventory_id].grid_slots[0][0]).is_equal(item_inst.item_instance_id)
	assert_int(test_inv.inventory_id).is_equal(item_inst.current_inventory_id)
	
	var start_inventory_id := test_inv.inventory_id
	var start_item_instance_id := item_inst.item_instance_id
	var start_item_3d_id := item_inst.id_3d
	var start_item_control_id := item_inst.id_2d
	
	#save data test
	SaveManager.save_game("test_values_save_and_load_correctly")
	var test_save_filename:String = "user://test_values_save_and_load_correctly.tres"
	
	#load save
	var loaded_game:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	loaded_game.level_scene_path = test_level_path
	
	assert_int(loaded_game.inventories.size()).is_equal(1)
	assert_int(loaded_game.item_instances.size()).is_equal(1)

	await SaveManager.load_game(test_save_filename)
	#same number of inventories and items after load
	assert_int(InventoryAccess.inventories.size()).is_equal(2)
	assert_int(ItemAccess.item_3ds.size()).is_equal(1)
	assert_int(ItemAccess.item_controls.size()).is_equal(1)
	assert_int(ItemAccess.item_instances.size()).is_equal(1)
	var new_inventory := InventoryAccess.get_inventory(start_inventory_id)
	assert_object(new_inventory).is_not_null()
	assert_int(new_inventory.grid_slots[0][0]).is_equal(start_item_instance_id)
	var new_item_inst := ItemAccess.get_item_instance(start_item_instance_id)
	assert_object(new_item_inst).is_not_null()
	assert_int(new_item_inst.item_instance_id).is_equal(start_item_instance_id)
	assert_int(new_item_inst.id_3d).is_equal(start_item_3d_id)
	assert_int(new_item_inst.id_2d).is_equal(start_item_control_id)
	var new_item_3d := ItemAccess.get_item_3d(new_item_inst.id_3d)
	assert_object(new_item_3d).is_not_null()
	assert_int(new_item_3d.item_instance_id).is_equal(start_item_instance_id)
	assert_int(new_item_3d.item_3d_id).is_equal(start_item_3d_id)
	assert_bool(new_item_3d.is_picked_up).is_true()
	var new_item_control := ItemAccess.get_item_control(new_item_inst.id_2d)
	assert_object(new_item_control).is_not_null()
	assert_int(new_item_control.item_instance_id).is_equal(start_item_instance_id)
	assert_int(new_item_control.item_control_id).is_equal(start_item_control_id)
	
	
