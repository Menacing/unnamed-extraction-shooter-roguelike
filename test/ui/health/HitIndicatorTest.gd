# GdUnit generated TestSuite
class_name HitIndicatorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://ui/health/HitIndicator.gd'


func test_deg_to_screen_edge() -> void:
	assert_vector(HitIndicator.deg_to_screen_edge(0,50,50)).is_equal(Vector2(25,0))
	assert_vector(HitIndicator.deg_to_screen_edge(-90,50,50)).is_equal(Vector2(50,25))
	assert_vector(HitIndicator.deg_to_screen_edge(-180,50,50)).is_equal(Vector2(25,50))
	assert_vector(HitIndicator.deg_to_screen_edge(90,50,50)).is_equal(Vector2(0,25))
	assert_vector(HitIndicator.deg_to_screen_edge(45,50,50)).is_equal(Vector2(0,0))


func test_convert_to_screen_coordinate() -> void:
	assert_vector(HitIndicator.convert_to_screen_coordinate(Vector2.ZERO, 10, 10)).is_equal(Vector2(5,5))
	assert_vector(HitIndicator.convert_to_screen_coordinate(Vector2(5,5), 10, 10)).is_equal(Vector2(10,0))
	assert_vector(HitIndicator.convert_to_screen_coordinate(Vector2(-5,-5), 10, 10)).is_equal(Vector2(0,10))


func test_is_in_view() -> void:
	assert_bool(HitIndicator.screen_coord_is_in_view(Vector2.ZERO,10,10)).is_true()
	assert_bool(HitIndicator.screen_coord_is_in_view(Vector2(10,10),10,10)).is_true()
	assert_bool(HitIndicator.screen_coord_is_in_view(Vector2(5,5),10,10)).is_true()
	assert_bool(HitIndicator.screen_coord_is_in_view(Vector2(-10,10),10,10)).is_false()
	assert_bool(HitIndicator.screen_coord_is_in_view(Vector2(10,100),10,10)).is_false()


func test_deg_to_vector2() -> void:
	assert_vector(HitIndicator.deg_to_vector2(0)).is_equal_approx(Vector2(0,1),Vector2(.01,.01))
	assert_vector(HitIndicator.deg_to_vector2(-90)).is_equal_approx(Vector2(1,0),Vector2(.01,.01))
	assert_vector(HitIndicator.deg_to_vector2(-180)).is_equal_approx(Vector2(0,-1),Vector2(.01,.01))
	assert_vector(HitIndicator.deg_to_vector2(90)).is_equal_approx(Vector2(-1,0),Vector2(.01,.01))


func test_deg_to_target() -> void:
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,0,Vector3.FORWARD)).is_equal(0)
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,0,Vector3.RIGHT)).is_equal(-90)
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,0,Vector3.LEFT)).is_equal(90)
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,0,Vector3.BACK)).is_equal(180)
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,-90,Vector3.BACK)).is_equal(-90)
	assert_int(HitIndicator.deg_to_target(Vector3.ZERO,90,Vector3.LEFT)).is_equal(0)
	
func test_deg_to_target_live_cases() -> void:
	assert_int(HitIndicator.deg_to_target(Vector3(-0.679,0,23.861), -10, Vector3(0.852, 0, 5.363))).is_between(-45,45)


func test_deg_to_vector3() -> void:
	assert_vector(HitIndicator.deg_to_vector3(0)).is_equal_approx(Vector3.FORWARD,Vector3(0.004,0.004,0.004))
	assert_vector(HitIndicator.deg_to_vector3(-90)).is_equal_approx(Vector3.RIGHT,Vector3(0.004,0.004,0.004))
	assert_vector(HitIndicator.deg_to_vector3(-180)).is_equal_approx(Vector3.BACK,Vector3(0.004,0.004,0.004))
	assert_vector(HitIndicator.deg_to_vector3(90)).is_equal_approx(Vector3.LEFT,Vector3(0.004,0.004,0.004))


func test_add_margin() -> void:
	assert_vector(HitIndicator.add_margin(Vector2.ZERO, 10,10,1)).is_equal(Vector2(1,1))
	assert_vector(HitIndicator.add_margin(Vector2(10,5), 10,10,1)).is_equal(Vector2(9,5))
	assert_vector(HitIndicator.add_margin(Vector2(10,10), 10,10,1)).is_equal(Vector2(9,9))
	assert_vector(HitIndicator.add_margin(Vector2(0,5), 10,10,1)).is_equal(Vector2(1,5))
