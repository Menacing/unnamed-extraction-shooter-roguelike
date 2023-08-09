# GdUnit generated TestSuite
class_name ItemAccessTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/item_access.gd'


func test_combine_stacks_fully_combined() -> void:
	#arrange
	var _itemAccess = ItemAccess.new()
	var item1:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.has_stacks = true
	
	item1._item_info = item_info
	item1.stacks = 1
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 3
	#act
	var result = _itemAccess.combine_stacks(item1, item2, 1)
	#assert
	assert_int(result).is_equal(0)

func test_combine_stacks_too_much_amount() -> void:
	#arrange
	var _itemAccess = ItemAccess.new()
	var item1:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.has_stacks = true
	
	item1._item_info = item_info
	item1.stacks = 1
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 3
	#act
	var result = _itemAccess.combine_stacks(item1, item2, 5)
	#assert
	assert_int(result).is_equal(0)
	assert_int(item1.stacks).is_equal(0)
	assert_int(item2.stacks).is_equal(4)

func test_combine_stacks_too_much_destination() -> void:
	#arrange
	var _itemAccess = ItemAccess.new()
	var item1:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.has_stacks = true
	
	item1._item_info = item_info
	item1.stacks = 5
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 3
	#act
	var result = _itemAccess.combine_stacks(item1, item2, 5)
	#assert
	assert_int(result).is_equal(3)
	assert_int(item1.stacks).is_equal(3)
	assert_int(item2.stacks).is_equal(5)
