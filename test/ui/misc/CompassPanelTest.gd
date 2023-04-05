# GdUnit generated TestSuite
class_name CompassPanelTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://ui/misc/CompassPanel.gd'


func test_degree_to_hscroll() -> void:
	assert_float(CompassBar.degree_to_hscroll(0,500)).is_equal_approx(500.0,0.01)
	assert_float(CompassBar.degree_to_hscroll(-90,500)).is_equal_approx(750.0,0.01)
	assert_float(CompassBar.degree_to_hscroll(-180,500)).is_equal_approx(1000.0,0.01)
	assert_float(CompassBar.degree_to_hscroll(180,500)).is_equal_approx(0.0,0.01)
	assert_float(CompassBar.degree_to_hscroll(90,500)).is_equal_approx(250.0,0.01)


func test_angle_to_deg() -> void:
	assert_int(CompassBar.angle_to_deg(Vector3.FORWARD, Vector3.RIGHT)).is_equal(-90)
	assert_int(CompassBar.angle_to_deg(Vector3.FORWARD, Vector3.LEFT)).is_equal(90)
	assert_int(CompassBar.angle_to_deg(Vector3.FORWARD, Vector3.FORWARD)).is_equal(0)
	assert_int(CompassBar.angle_to_deg(Vector3.FORWARD, Vector3.BACK)).is_equal(180)


func test_combine_degrees() -> void:
	assert_int(CompassBar.combine_degrees(0,0)).is_equal(0)
	assert_int(CompassBar.combine_degrees(0,-90)).is_equal(-90)
	assert_int(CompassBar.combine_degrees(0,90)).is_equal(90)
	assert_int(CompassBar.combine_degrees(90,90)).is_equal(0)
	assert_int(CompassBar.combine_degrees(90,-90)).is_equal(-180)
	assert_int(CompassBar.combine_degrees(-90,90)).is_equal(180)
