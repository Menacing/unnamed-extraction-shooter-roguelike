# GdUnit generated TestSuite
class_name InventoryManagerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_logic/inventory_manager.gd'

@onready var test_inv:Inventory = load("res://test/resource_access/test_inventory.tres")
@onready var item_info:ItemInformation = load("res://game_objects/items/materials/polymer_pile/polymer_pile_inventory_info.tres")
@onready var item_inst:ItemInstance = ItemInstance.new(item_info)
func before():
	test_inv.setup()
	item_inst.spawn_item()
	InventoryManager._on_pickup_item(item_inst, test_inv.inventory_id)

func test__on_game_saving() -> void:
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_int(ItemAccess.item_3ds.size()).is_equal(1)
	assert_int(ItemAccess.item_controls.size()).is_equal(1)
	assert_int(ItemAccess.item_instances.size()).is_equal(1)
	
	#save data test
	SaveManager.save_game("test_values_save_and_load_correctly")
	var test_save_filename:String = "user://test_values_save_and_load_correctly.tres"
	
	#load save
	var loaded_game:SaveFile = SafeResourceLoader.load(test_save_filename) as SaveFile
	
	assert_int(loaded_game.inventories.size()).is_equal(1)
	assert_int(loaded_game.item_instances.size()).is_equal(1)

	SaveManager.load_game(test_save_filename)
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_int(ItemAccess.item_3ds.size()).is_equal(1)
	assert_int(ItemAccess.item_controls.size()).is_equal(1)
	assert_int(ItemAccess.item_instances.size()).is_equal(1)
	
