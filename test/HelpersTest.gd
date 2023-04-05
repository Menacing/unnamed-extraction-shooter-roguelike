# GdUnit generated TestSuite
class_name HelpersTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://Helpers.gd'


func test_normalize_deg() -> void:
	assert_int(Helpers.gddeg_to_compass_deg(0)).is_equal(0)
	assert_int(Helpers.gddeg_to_compass_deg(-90)).is_equal(90)
	assert_int(Helpers.gddeg_to_compass_deg(180)).is_equal(180)
	assert_int(Helpers.gddeg_to_compass_deg(-180)).is_equal(180)
	assert_int(Helpers.gddeg_to_compass_deg(90)).is_equal(270)

