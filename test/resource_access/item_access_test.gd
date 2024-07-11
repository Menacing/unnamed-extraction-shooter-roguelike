# GdUnit generated TestSuite
class_name ItemAccessTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/item_access.gd'


func test_combine_stacks_fully_combined() -> void:
	#arrange
	var _itemAccess = ItemAccess
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.max_stacks = 5
	item_info.has_stacks = true
	var item1:ItemInstance = ItemInstance.new(item_info)
	
	
	item1.stacks = 1
	
	var item2:ItemInstance = ItemInstance.new(item_info)
	item2._item_info = item_info
	item2.stacks = 3
	#act
	var result = _itemAccess.combine_stacks(item1, item2, 1)
	#assert
	assert_int(result).is_equal(0)

func test_combine_stacks_too_much_amount() -> void:
	#arrange
	var _itemAccess = ItemAccess
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.max_stacks = 5
	item_info.has_stacks = true
	var item1:ItemInstance = ItemInstance.new(item_info)
	
	
	item1.stacks = 1
	
	var item2:ItemInstance = ItemInstance.new(item_info)
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
	var _itemAccess = ItemAccess
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.max_stacks = 5
	item_info.has_stacks = true
	var item1:ItemInstance = ItemInstance.new(item_info)
	
	
	item1.stacks = 5
	
	var item2:ItemInstance = ItemInstance.new(item_info)
	item2._item_info = item_info
	item2.stacks = 3
	#act
	var result = _itemAccess.combine_stacks(item1, item2, 5)
	#assert
	assert_int(result).is_equal(3)
	assert_int(item1.stacks).is_equal(3)
	assert_int(item2.stacks).is_equal(5)


func test_clone_instance() -> void:
	#arrange
	var _itemAccess = ItemAccess
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.max_stacks = 5
	item_info.has_stacks = true
	var item1:ItemInstance = ItemInstance.new(item_info)
	
	
	item1.stacks = 5
	var node1 = ItemControl.new()
	node1.item_control_id = Helpers.generate_new_id()
	item1.id_2d = node1.item_control_id
	
	#act
	var dupe:ItemInstance = _itemAccess.clone_instance(item1)
	
	#assert
	assert_bool(dupe != null).is_true()
	assert_bool(item1.item_instance_id != dupe.item_instance_id).is_true()
	assert_bool(item1.id_2d != dupe.id_2d).is_true()
	assert_bool(dupe.id_2d != 0).is_true()
	assert_bool(item1.stacks == dupe.stacks).is_true()
	assert_bool(item1.get_height() == dupe.get_height()).is_true()
