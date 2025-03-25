# GdUnit generated TestSuite
class_name InventoryDataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/inventory_data.gd'


func test_number_items_of_type() -> void:

	#arrange
	var inventory_data:InventoryData = load("res://test/resource_access/4x4_test_inventory.tres")
	#act
	
	var count = inventory_data.number_items_of_type("polymer_spool_medium")
	
	#assert
	assert_int(count).is_equal(2)
	

func test_number_items_of_type_two_items() -> void:

	#arrange
	var inventory_data:InventoryData = load("res://test/resource_access/4x4_test_inventory_two_items.tres")
	#act
	
	var count = inventory_data.number_items_of_type("regel_pod")
	
	#assert
	assert_int(count).is_equal(8)
