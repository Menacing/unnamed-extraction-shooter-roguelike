extends AnimatableBody3D
class_name SteppingCharacterBody3D

enum MotionMode { MOTION_MODE_GROUNDED, MOTION_MODE_FLOATING }
const FLOOR_ANGLE_THRESHOLD = 0.01
const CMP_EPSILON = 0.00001

##Max angle 
@export var floor_max_angle:float = 0.785398
@export var floor_snap_length:float = 0.1
@export var floor_stop_on_slope:bool = true
@export var max_slides:int = 6
@export var velocity:Vector3 = Vector3(0,0,0)
@export var up_direction:Vector3 = Vector3(0,1,0)
@export var motion_mode:MotionMode = MotionMode.MOTION_MODE_GROUNDED
@export var safe_margin:float = 0.001
@export var wall_min_slide_angle:float = 0.261799

var _collision_results:Array[KinematicCollision3D] = []
var _floor_normal:Vector3
var _wall_normal:Vector3
var _ceiling_normal:Vector3
var _collision_state:CollisionState
var _platform_rid:RID
var _platform_object_id:int
var _platform_velocity:Vector3
var _platform_angular_velocity:Vector3
var _platform_layer:int
var _platform_ceiling_velocity:Vector3
var _last_motion:Vector3

func apply_floor_snap():
	#if (collision_state.floor) {
		#return;
	#}
#
	#// Snap by at least collision margin to keep floor state consistent.
	#real_t length = MAX(floor_snap_length, margin);
#
	#PhysicsServer3D::MotionParameters parameters(get_global_transform(), -up_direction * length, margin);
	#parameters.max_collisions = 4;
	#parameters.recovery_as_collision = true; // Also report collisions generated only from recovery.
	#parameters.collide_separation_ray = true;
#
	#PhysicsServer3D::MotionResult result;
	#if (move_and_collide(parameters, result, true, false)) {
		#CollisionState result_state;
		#// Apply direction for floor only.
		#_set_collision_direction(result, result_state, CollisionState(true, false, false));
#
		#if (result_state.floor) {
			#if (floor_stop_on_slope) {
				#// move and collide may stray the object a bit because of pre un-stucking,
				#// so only ensure that motion happens on floor direction in this case.
				#if (result.travel.length() > margin) {
					#result.travel = up_direction * up_direction.dot(result.travel);
				#} else {
					#result.travel = Vector3();
				#}
			#}
#
			#parameters.from.origin += result.travel;
			#set_global_transform(parameters.from);
		#}
	#}
#}
	pass
	
func is_on_floor() -> bool:
	return false
	
func is_on_floor_only() -> bool:
	return false and !is_on_wall() and !is_on_ceiling()
	
func is_on_wall() -> bool:
	return false
	
func is_on_wall_only() -> bool:
	return false and !is_on_floor() and !is_on_ceiling()
	
func is_on_ceiling() -> bool:
	return false

func is_on_ceiling_only() -> bool:
	return false and !is_on_floor() and !is_on_wall()

func get_floor_normal() -> Vector3:
	return _floor_normal

func move_step_and_slide(delta:float) -> bool:
	
	#for (int i = 0; i < 3; i++) {
		#if (locked_axis & (1 << i)) {
			#velocity[i] = 0.0;
		#}
	#}
#
	#Transform3D gt = get_global_transform();
	#previous_position = gt.origin;
#
	#Vector3 current_platform_velocity = platform_velocity;
#
	#if ((collision_state.floor || collision_state.wall) && platform_rid.is_valid()) {
		#bool excluded = false;
		#if (collision_state.floor) {
			#excluded = (platform_floor_layers & platform_layer) == 0;
		#} else if (collision_state.wall) {
			#excluded = (platform_wall_layers & platform_layer) == 0;
		#}
		#if (!excluded) {
			#//this approach makes sure there is less delay between the actual body velocity and the one we saved
			#PhysicsDirectBodyState3D *bs = PhysicsServer3D::get_singleton()->body_get_direct_state(platform_rid);
			#if (bs) {
				#Vector3 local_position = gt.origin - bs->get_transform().origin;
				#current_platform_velocity = bs->get_velocity_at_local_position(local_position);
			#} else {
				#// Body is removed or destroyed, invalidate floor.
				#current_platform_velocity = Vector3();
				#platform_rid = RID();
			#}
		#} else {
			#current_platform_velocity = Vector3();
		#}
	#}
#
	#motion_results.clear();
#
	#var was_on_floor:bool = collision_state.floor
	var was_on_floor:bool
	
	#collision_state.state = 0;
#
	#last_motion = Vector3();
#
	#if (!current_platform_velocity.is_zero_approx()) {
		#PhysicsServer3D::MotionParameters parameters(get_global_transform(), current_platform_velocity * delta, margin);
		#parameters.recovery_as_collision = true; // Also report collisions generated only from recovery.
#
		#parameters.exclude_bodies.insert(platform_rid);
		#if (platform_object_id.is_valid()) {
			#parameters.exclude_objects.insert(platform_object_id);
		#}
#
		#PhysicsServer3D::MotionResult floor_result;
		#if (move_and_collide(parameters, floor_result, false, false)) {
			#motion_results.push_back(floor_result);
#
			#CollisionState result_state;
			#_set_collision_direction(floor_result, result_state);
		#}
	#}
#
	if (motion_mode == MotionMode.MOTION_MODE_GROUNDED):
		_move_step_and_slide_grounded(delta, was_on_floor)
	else:
		_move_step_and_slide_floating(delta)

#
	#// Compute real velocity.
	#real_velocity = get_position_delta() / delta;
#
	#if (platform_on_leave != PLATFORM_ON_LEAVE_DO_NOTHING) {
		#// Add last platform velocity when just left a moving platform.
		#if (!collision_state.floor && !collision_state.wall) {
			#if (platform_on_leave == PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY && current_platform_velocity.dot(up_direction) < 0) {
				#current_platform_velocity = current_platform_velocity.slide(up_direction);
			#}
			#velocity += current_platform_velocity;
		#}
	#}
	
	return _collision_results.size() > 0 
	pass

func _move_step_and_slide_grounded(delta:float, was_on_floor:bool):
	var motion:Vector3 = velocity * delta;
	var motion_slide_up:Vector3 = motion.slide(up_direction);
	var prev_floor_normal:Vector3 = _floor_normal;
	
	var current_frame_moves:Array[Vector3] = []

	#platform_rid = RID();
	#platform_object_id = ObjectID();
	#platform_velocity = Vector3();
	#platform_angular_velocity = Vector3();
	#platform_ceiling_velocity = Vector3();
	_floor_normal = Vector3()
	_wall_normal = Vector3()
	_ceiling_normal = Vector3()

	#No sliding on first attempt to keep floor motion stable when possible,
	#When stop on slope is enabled or when there is no up direction.
	var sliding_enabled:bool = !floor_stop_on_slope;
	#Constant speed can be applied only the first time sliding is enabled.
	var can_apply_constant_speed:bool = sliding_enabled;
	#If the platform's ceiling push down the body.
	var apply_ceiling_velocity:bool = false;
	var first_slide:bool = true;
	var vel_dir_facing_up:bool = velocity.dot(up_direction) > 0;
	var total_travel:Vector3
	var current_frame_transform:Transform3D = global_transform

	for iteration in range(max_slides):
		#There can be 4 collisions between 2 walls + 2 more for the floor.
		#Also report collisions generated only from recovery.
		var result:KinematicCollision3D = KinematicCollision3D.new()
		var collided = test_move(current_frame_transform, motion, result, safe_margin, true, 6)

		if (collided):
			_collision_results.append(result);
#
			var previous_state:CollisionState = _collision_state;
#
			var result_state:CollisionState
			_set_collision_direction(result, result_state, CollisionState.new(true,true,true));
#
			#// If we hit a ceiling platform, we set the vertical velocity to at least the platform one.
			#if (collision_state.ceiling && platform_ceiling_velocity != Vector3() && platform_ceiling_velocity.dot(up_direction) < 0) {
				#// If ceiling sliding is on, only apply when the ceiling is flat or when the motion is upward.
				#if (!slide_on_ceiling || motion.dot(up_direction) < 0 || (ceiling_normal + up_direction).length() < 0.01) {
					#apply_ceiling_velocity = true;
					#Vector3 ceiling_vertical_velocity = up_direction * up_direction.dot(platform_ceiling_velocity);
					#Vector3 motion_vertical_velocity = up_direction * up_direction.dot(velocity);
					#if (motion_vertical_velocity.dot(up_direction) > 0 || ceiling_vertical_velocity.length_squared() > motion_vertical_velocity.length_squared()) {
						#velocity = ceiling_vertical_velocity + velocity.slide(up_direction);
					#}
				#}
			#}
#
			#if (collision_state.floor && floor_stop_on_slope && (velocity.normalized() + up_direction).length() < 0.01) {
				#Transform3D gt = get_global_transform();
				#if (result.travel.length() <= margin + CMP_EPSILON) {
					#gt.origin -= result.travel;
				#}
				#set_global_transform(gt);
				#velocity = Vector3();
				#motion = Vector3();
				#last_motion = Vector3();
				#break;
			#}
#
			#if (result.remainder.is_zero_approx()) {
				#motion = Vector3();
				#break;
			#}
#
			#// Apply regular sliding by default.
			#bool apply_default_sliding = true;
#
			#// Wall collision checks.
			#if (result_state.wall && (motion_slide_up.dot(wall_normal) <= 0)) {
				#// Move on floor only checks.
				#if (floor_block_on_wall) {
					#// Needs horizontal motion from current motion instead of motion_slide_up
					#// to properly test the angle and avoid standing on slopes
					#Vector3 horizontal_motion = motion.slide(up_direction);
					#Vector3 horizontal_normal = wall_normal.slide(up_direction).normalized();
					#real_t motion_angle = Math::abs(Math::acos(-horizontal_normal.dot(horizontal_motion.normalized())));
#
					#// Avoid to move forward on a wall if floor_block_on_wall is true.
					#// Applies only when the motion angle is under 90 degrees,
					#// in order to avoid blocking lateral motion along a wall.
					#if (motion_angle < .5 * Math_PI) {
						#apply_default_sliding = false;
						#if (p_was_on_floor && !vel_dir_facing_up) {
							#// Cancel the motion.
							#Transform3D gt = get_global_transform();
							#real_t travel_total = result.travel.length();
							#real_t cancel_dist_max = MIN(0.1, margin * 20);
							#if (travel_total <= margin + CMP_EPSILON) {
								#gt.origin -= result.travel;
								#result.travel = Vector3(); // Cancel for constant speed computation.
							#} else if (travel_total < cancel_dist_max) { // If the movement is large the body can be prevented from reaching the walls.
								#gt.origin -= result.travel.slide(up_direction);
								#// Keep remaining motion in sync with amount canceled.
								#motion = motion.slide(up_direction);
								#result.travel = Vector3();
							#} else {
								#// Travel is too high to be safely canceled, we take it into account.
								#result.travel = result.travel.slide(up_direction);
								#motion = motion.normalized() * result.travel.length();
							#}
							#set_global_transform(gt);
							#// Determines if you are on the ground, and limits the possibility of climbing on the walls because of the approximations.
							#_snap_on_floor(true, false);
						#} else {
							#// If the movement is not canceled we only keep the remaining.
							#motion = result.remainder;
						#}
#
						#// Apply slide on forward in order to allow only lateral motion on next step.
						#Vector3 forward = wall_normal.slide(up_direction).normalized();
						#motion = motion.slide(forward);
#
						#// Scales the horizontal velocity according to the wall slope.
						#if (vel_dir_facing_up) {
							#Vector3 slide_motion = velocity.slide(result.collisions[0].normal);
							#// Keeps the vertical motion from velocity and add the horizontal motion of the projection.
							#velocity = up_direction * up_direction.dot(velocity) + slide_motion.slide(up_direction);
						#} else {
							#velocity = velocity.slide(forward);
						#}
#
						#// Allow only lateral motion along previous floor when already on floor.
						#// Fixes slowing down when moving in diagonal against an inclined wall.
						#if (p_was_on_floor && !vel_dir_facing_up && (motion.dot(up_direction) > 0.0)) {
							#// Slide along the corner between the wall and previous floor.
							#Vector3 floor_side = prev_floor_normal.cross(wall_normal);
							#if (floor_side != Vector3()) {
								#motion = floor_side * motion.dot(floor_side);
							#}
						#}
#
						#// Stop all motion when a second wall is hit (unless sliding down or jumping),
						#// in order to avoid jittering in corner cases.
						#bool stop_all_motion = previous_state.wall && !vel_dir_facing_up;
#
						#// Allow sliding when the body falls.
						#if (!collision_state.floor && motion.dot(up_direction) < 0) {
							#Vector3 slide_motion = motion.slide(wall_normal);
							#// Test again to allow sliding only if the result goes downwards.
							#// Fixes jittering issues at the bottom of inclined walls.
							#if (slide_motion.dot(up_direction) < 0) {
								#stop_all_motion = false;
								#motion = slide_motion;
							#}
						#}
#
						#if (stop_all_motion) {
							#motion = Vector3();
							#velocity = Vector3();
						#}
					#}
				#}
#
				#// Stop horizontal motion when under wall slide threshold.
				#if (p_was_on_floor && (wall_min_slide_angle > 0.0) && result_state.wall) {
					#Vector3 horizontal_normal = wall_normal.slide(up_direction).normalized();
					#real_t motion_angle = Math::abs(Math::acos(-horizontal_normal.dot(motion_slide_up.normalized())));
					#if (motion_angle < wall_min_slide_angle) {
						#motion = up_direction * motion.dot(up_direction);
						#velocity = up_direction * velocity.dot(up_direction);
#
						#apply_default_sliding = false;
					#}
				#}
			#}
#
			#if (apply_default_sliding) {
				#// Regular sliding, the last part of the test handle the case when you don't want to slide on the ceiling.
				#if ((sliding_enabled || !collision_state.floor) && (!collision_state.ceiling || slide_on_ceiling || !vel_dir_facing_up) && !apply_ceiling_velocity) {
					#const PhysicsServer3D::MotionCollision &collision = result.collisions[0];
#
					#Vector3 slide_motion = result.remainder.slide(collision.normal);
					#if (collision_state.floor && !collision_state.wall && !motion_slide_up.is_zero_approx()) {
						#// Slide using the intersection between the motion plane and the floor plane,
						#// in order to keep the direction intact.
						#real_t motion_length = slide_motion.length();
						#slide_motion = up_direction.cross(result.remainder).cross(floor_normal);
#
						#// Keep the length from default slide to change speed in slopes by default,
						#// when constant speed is not enabled.
						#slide_motion.normalize();
						#slide_motion *= motion_length;
					#}
#
					#if (slide_motion.dot(velocity) > 0.0) {
						#motion = slide_motion;
					#} else {
						#motion = Vector3();
					#}
#
					#if (slide_on_ceiling && result_state.ceiling) {
						#// Apply slide only in the direction of the input motion, otherwise just stop to avoid jittering when moving against a wall.
						#if (vel_dir_facing_up) {
							#velocity = velocity.slide(collision.normal);
						#} else {
							#// Avoid acceleration in slope when falling.
							#velocity = up_direction * up_direction.dot(velocity);
						#}
					#}
				#}
				#// No sliding on first attempt to keep floor motion stable when possible.
				#else {
					#motion = result.remainder;
					#if (result_state.ceiling && !slide_on_ceiling && vel_dir_facing_up) {
						#velocity = velocity.slide(up_direction);
						#motion = motion.slide(up_direction);
					#}
				#}
			#}
#
			#total_travel += result.travel;
#
			#// Apply Constant Speed.
			#if (p_was_on_floor && floor_constant_speed && can_apply_constant_speed && collision_state.floor && !motion.is_zero_approx()) {
				#Vector3 travel_slide_up = total_travel.slide(up_direction);
				#motion = motion.normalized() * MAX(0, (motion_slide_up.length() - travel_slide_up.length()));
			#}
		#}
		#// When you move forward in a downward slope you don’t collide because you will be in the air.
		#// This test ensures that constant speed is applied, only if the player is still on the ground after the snap is applied.
		#else if (floor_constant_speed && first_slide && _on_floor_if_snapped(p_was_on_floor, vel_dir_facing_up)) {
			#can_apply_constant_speed = false;
			#sliding_enabled = true;
			#Transform3D gt = get_global_transform();
			#gt.origin = gt.origin - result.travel;
			#set_global_transform(gt);
#
			#// Slide using the intersection between the motion plane and the floor plane,
			#// in order to keep the direction intact.
			#Vector3 motion_slide_norm = up_direction.cross(motion).cross(prev_floor_normal);
			#motion_slide_norm.normalize();
#
			#motion = motion_slide_norm * (motion_slide_up.length());
			#collided = true;
		#}
#
		#if (!collided || motion.is_zero_approx()) {
			#break;
		#}
#
		#can_apply_constant_speed = !can_apply_constant_speed && !sliding_enabled;
		#sliding_enabled = true;
		#first_slide = false;
	#}
#
	#_snap_on_floor(p_was_on_floor, vel_dir_facing_up);
#
	#// Reset the gravity accumulation when touching the ground.
	#if (collision_state.floor && !vel_dir_facing_up) {
		#velocity = velocity.slide(up_direction);
	#}
	pass

func _move_step_and_slide_floating(p_delta: float) -> void:
	var motion: Vector3 = velocity * p_delta

	_platform_rid = RID()
	_platform_object_id = 0
	_floor_normal = Vector3()
	_platform_velocity = Vector3()
	_platform_angular_velocity = Vector3()

	var first_slide: bool = true
	for iteration in range(max_slides):
		# Also report collisions generated only from recovery.
		var result:KinematicCollision3D = KinematicCollision3D.new()
		var collided: bool = test_move(global_transform, motion, result, safe_margin, true)

		_last_motion = result.travel

		if collided:
			_collision_results.push_back(result)

			var result_state = {} # Placeholder for your specific collision state handling
			_set_collision_direction(result, result_state, CollisionState.new(true,true,true))

			if result.remainder.is_equal_approx(Vector3.ZERO):
				motion = Vector3.ZERO
				break

			if wall_min_slide_angle != 0 and acos(_wall_normal.dot(-velocity.normalized())) < wall_min_slide_angle + FLOOR_ANGLE_THRESHOLD:
				motion = Vector3.ZERO
				if result.travel.length() < safe_margin + CMP_EPSILON:
					var gt: Transform3D = get_global_transform()
					gt.origin -= result.travel
					set_global_transform(gt)
			elif first_slide:
				var motion_slide_norm: Vector3 = result.remainder.slide(_wall_normal).normalized()
				motion = motion_slide_norm * (motion.length() - result.travel.length())
			else:
				motion = result.remainder.slide(_wall_normal)

			if motion.dot(velocity) <= 0.0:
				motion = Vector3.ZERO

		if not collided or motion.is_equal_approx(Vector3.ZERO):
			break

		first_slide = false


func _set_collision_direction(p_result:KinematicCollision3D, r_state:CollisionState, p_apply_state:CollisionState):
	r_state.state = 0

	var wall_depth: float = -1.0
	var floor_depth: float = -1.0

	var was_on_wall: bool = _collision_state.wall
	var prev_wall_normal: Vector3 = _wall_normal
	var wall_collision_count: int = 0
	var combined_wall_normal: Vector3 = Vector3.ZERO
	var tmp_wall_col: Vector3 = Vector3.ZERO # Avoid duplicate on average calculation.

	for i in range(p_result.collision_count - 1, -1, -1):
		var collision = p_result.collisions[i]

		if motion_mode == MotionMode.MOTION_MODE_GROUNDED:
			# Check if any collision is floor.
			var floor_angle = collision.get_angle(up_direction)
			if floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
				r_state.floor = true
				if p_apply_state.floor and collision.depth > floor_depth:
					_collision_state.floor = true
					_floor_normal = collision.normal
					floor_depth = collision.depth
					_set_platform_data(collision)
				continue

			# Check if any collision is ceiling.
			var ceiling_angle = collision.get_angle(-up_direction)
			if ceiling_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
				r_state.ceiling = true
				if p_apply_state.ceiling:
					_platform_ceiling_velocity = collision.collider_velocity
					_ceiling_normal = collision.normal
					_collision_state.ceiling = true
				continue

		# Collision is wall by default.
		r_state.wall = true

		if p_apply_state.wall and collision.depth > wall_depth:
			_collision_state.wall = true
			wall_depth = collision.depth
			_wall_normal = collision.normal

			# Don't apply wall velocity when the collider is a CharacterBody3D.
			if collision.collider_id is CharacterBody3D:
				_set_platform_data(collision)

		# Collect normal for calculating average.
		if not collision.normal.is_equal_approx(tmp_wall_col):
			tmp_wall_col = collision.normal
			combined_wall_normal += collision.normal
			wall_collision_count += 1

	if r_state.wall:
		if wall_collision_count > 1 and not r_state.floor:
			# Check if wall normals cancel out to floor support.
			if not r_state.floor and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
				combined_wall_normal = combined_wall_normal.normalized()
				var floor_angle = acos(combined_wall_normal.dot(up_direction))
				if floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
					r_state.floor = true
					r_state.wall = false
					if p_apply_state.floor:
						_collision_state.floor = true
						_floor_normal = combined_wall_normal
					if p_apply_state.wall:
						_collision_state.wall = was_on_wall
						_wall_normal = prev_wall_normal
					return

func _set_platform_data(p_collision):
	_platform_rid = p_collision.collider
	_platform_object_id = p_collision.collider_id
	_platform_velocity = p_collision.collider_velocity
	_platform_angular_velocity = p_collision.collider_angular_velocity
	_platform_layer = PhysicsServer3D.body_get_collision_layer(_platform_rid)


class CollisionState:
	var state:int = 0
	var floor:bool = false
	var wall:bool = false
	var ceiling:bool = false
	
	func _init(_floor:bool, _wall:bool, _ceiling:bool) -> void:
		floor = _floor
		wall = _wall
		ceiling = _ceiling
