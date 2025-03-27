# GdUnit generated TestSuite
class_name HelpersTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://helpers/helpers.gd'

func test_normalize_deg() -> void:
	assert_int(Helpers.gddeg_to_compass_deg(0)).is_equal(0)
	assert_int(Helpers.gddeg_to_compass_deg(-90)).is_equal(90)
	assert_int(Helpers.gddeg_to_compass_deg(180)).is_equal(180)
	assert_int(Helpers.gddeg_to_compass_deg(-180)).is_equal(180)
	assert_int(Helpers.gddeg_to_compass_deg(90)).is_equal(270)

func test_duplicate_deep_workaround_dictionary() -> void:
	#arrange
	var dic1 = {
		1: "test",
		2: "test2"
	}
	var dic2 = dic1
	
	var dic3 = Helpers.duplicate_deep_workaround_dictionary(dic1)
	
	dic1[1] = "new value"

	assert_str(dic1[1]).is_equal(dic2[1])
	assert_str(dic1[1]).is_not_equal(dic3[1])

func test_duplicate_deep_workaround_dictionary_nested() -> void:
	#arrange
	var dic1 = {
		1: "test",
		2: "test2",
		3: {
			1:"nested value"
		}
	}
	var dic2 = dic1
	
	#act
	var dic3 = Helpers.duplicate_deep_workaround_dictionary(dic1)
	dic1[3][1] = "new value"

	#assert
	assert_str(dic1[1]).is_equal(dic2[1])
	assert_str(dic1[3][1]).is_equal(dic2[3][1])
	assert_str(dic1[3][1]).is_not_equal(dic3[3][1])

func test_duplicate_deep_workaround_dictionary_resource() -> void:
	#arrange
	var arr1 = {}
	
	var aci1 = AmmoCountInfo.new()
	aci1.current_amount = 1
	aci1.current_max = 1
	aci1.subtype_item_id = "test1"
	arr1[0] = aci1
	
	var aci2 = AmmoCountInfo.new()
	aci2.current_amount = 2
	aci2.current_max = 2
	aci2.subtype_item_id = "test2"
	arr1[1] = aci2
	
	var aci3 = AmmoCountInfo.new()
	aci3.current_amount = 3
	aci3.current_max = 3
	aci3.subtype_item_id = "test3"
	arr1[2] = aci3

	var arr2 = arr1
	
	#act
	var arr3 = Helpers.duplicate_deep_workaround_dictionary(arr1)
	arr3[0].subtype_item_id = "new value"
	
	#assert
	assert_str(arr3[0].subtype_item_id).is_not_equal(arr1[0].subtype_item_id)
	assert_str(arr2[0].subtype_item_id).is_equal(arr1[0].subtype_item_id)


func test_duplicate_deep_workaround_array() -> void:
	#arrange
	var arr1:Array[AmmoCountInfo] = []
	
	var aci1 = AmmoCountInfo.new()
	aci1.current_amount = 1
	aci1.current_max = 1
	aci1.subtype_item_id = "test1"
	arr1.append(aci1)
	
	var aci2 = AmmoCountInfo.new()
	aci2.current_amount = 2
	aci2.current_max = 2
	aci2.subtype_item_id = "test2"
	arr1.append(aci2)
	
	var aci3 = AmmoCountInfo.new()
	aci3.current_amount = 3
	aci3.current_max = 3
	aci3.subtype_item_id = "test3"
	arr1.append(aci3)

	var arr2 = arr1
	
	#act
	var arr3 = Helpers.duplicate_deep_workaround_array(arr1)
	arr3[0].subtype_item_id = "new value"
	
	#assert
	assert_str(arr3[0].subtype_item_id).is_not_equal(arr1[0].subtype_item_id)
	assert_str(arr2[0].subtype_item_id).is_equal(arr1[0].subtype_item_id)
