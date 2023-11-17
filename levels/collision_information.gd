extends RefCounted
class_name CollisionInformation

var position:Vector3
var normal:Vector3
var collider:Object

static func map_from_ray_result(ray_result:Dictionary)-> CollisionInformation:
	var result = CollisionInformation.new()
	result.position = ray_result.position
	result.normal = ray_result.normal
	result.collider = ray_result.collider
	return result

static func map_from_kinematic_collision_3d(kin_con:KinematicCollision3D)-> CollisionInformation:
	var result = CollisionInformation.new()
	result.position = kin_con.get_position()
	result.normal = kin_con.get_normal()
	result.collider = kin_con.get_collider()
	return result
