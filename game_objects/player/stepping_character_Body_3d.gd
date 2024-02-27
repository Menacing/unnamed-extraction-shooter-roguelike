extends AnimatableBody3D
class_name SteppingCharacterBody3D

enum MotionMode { MOTION_MODE_GROUNDED, MOTION_MODE_FLOATING }
enum PlatformOnLeave { PLATFORM_ON_LEAVE_ADD_VELOCITY, PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY, PLATFORM_ON_LEAVE_DO_NOTHING }
const FLOOR_ANGLE_THRESHOLD = 0.01
const CMP_EPSILON = 0.00001

##Max angle 
@export var floor_block_on_wall:bool = true
@export var floor_constant_speed:bool = false
@export var floor_max_angle:float = 0.785398
@export var floor_snap_length:float = 0.1
@export var floor_stop_on_slope:bool = true
@export var max_slides:int = 6
@export var velocity:Vector3 = Vector3(0,0,0)
@export var up_direction:Vector3 = Vector3(0,1,0)
@export var motion_mode:MotionMode = MotionMode.MOTION_MODE_GROUNDED
@export var safe_margin:float = 0.001
@export var slide_on_ceiling:bool = true
@export var wall_min_slide_angle:float = 0.261799
@export var platform_on_leave:PlatformOnLeave = PlatformOnLeave.PLATFORM_ON_LEAVE_ADD_VELOCITY
@export var max_step_height = .45
@export var min_step_width = .125

var _collision_results:Array[KinematicCollision3D] = []
var _floor_normal:Vector3
var _wall_normal:Vector3
var _ceiling_normal:Vector3
var _collision_state:CollisionState = CollisionState.new(false,false,false)
var _platform_rid:RID
var _platform_object_id:int
var _platform_velocity:Vector3
var _platform_angular_velocity:Vector3
var _platform_layer:int
var _platform_floor_layers:int = 4294967295
var _platform_ceiling_velocity:Vector3
var _platform_wall_layers:int = 0
var _last_motion:Vector3
var _previous_position:Vector3
var _real_velocity:Vector3


func is_on_floor() -> bool:
	return _collision_state.floor
	
func is_on_floor_only() -> bool:
	return _collision_state.floor and !is_on_wall() and !is_on_ceiling()
	
func is_on_wall() -> bool:
	return _collision_state.wall
	
func is_on_wall_only() -> bool:
	return _collision_state.wall and !is_on_floor() and !is_on_ceiling()
	
func is_on_ceiling() -> bool:
	return _collision_state.ceiling

func is_on_ceiling_only() -> bool:
	return _collision_state.ceiling and !is_on_floor() and !is_on_wall()

func get_floor_normal() -> Vector3:
	return _floor_normal

func move_step_and_slide(delta:float) -> bool:

	if axis_lock_linear_x:
		velocity.x = 0.0
	if axis_lock_linear_y:
		velocity.y = 0.0
	if axis_lock_linear_z:
		velocity.z = 0.0

	var gt = get_global_transform()
	_previous_position = gt.origin

	var current_platform_velocity = _platform_velocity

	if (_collision_state.floor or _collision_state.wall) and _platform_rid.is_valid():
		var excluded = false
		if _collision_state.floor:
			excluded = (_platform_floor_layers & _platform_layer) == 0
		elif _collision_state.wall:
			excluded = (_platform_wall_layers & _platform_layer) == 0

		if not excluded:
			# This approach makes sure there is less delay between the actual body velocity and the one we saved
			var bs = PhysicsServer3D.body_get_direct_state(_platform_rid)
			if bs:
				var local_position = gt.origin - bs.get_transform().origin
				current_platform_velocity = bs.get_velocity_at_local_position(local_position)
			else:
				# Body is removed or destroyed, invalidate floor.
				current_platform_velocity = Vector3()
				_platform_rid = RID()
		else:
			current_platform_velocity = Vector3()

	_collision_results.clear()

	var was_on_floor = _collision_state.floor
	_collision_state.state = 0

	_last_motion = Vector3()

	if not current_platform_velocity.is_equal_approx(Vector3.ZERO):
		# Also report collisions generated only from recovery.
		var platform_node = instance_from_id(_platform_object_id)
		if platform_node:
			add_collision_exception_with(platform_node)

		var floor_result = move_and_collide(current_platform_velocity * delta, false, safe_margin, true)
		if floor_result:
			_collision_results.push_back(floor_result)

			#Initialize your collision state structure
			var result_state:CollisionState = CollisionState.new(false,false,false) 
			_set_collision_direction(floor_result, result_state, CollisionState.new(true,true,true))

	if motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		_move_step_and_slide_grounded(delta, was_on_floor)
	else:
		_move_step_and_slide_floating(delta)

	# Compute real velocity.
	_real_velocity = (global_position - _previous_position) / delta

	if platform_on_leave != PlatformOnLeave.PLATFORM_ON_LEAVE_DO_NOTHING:
		# Add last platform velocity when just left a moving platform.
		if not _collision_state.floor and not _collision_state.wall:
			if platform_on_leave == PlatformOnLeave.PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY and current_platform_velocity.dot(up_direction) < 0:
				current_platform_velocity = current_platform_velocity.slide(up_direction)
			velocity += current_platform_velocity

	return len(_collision_results) > 0


func _move_step_and_slide_grounded(delta:float, was_on_floor:bool):
	var motion:Vector3 = velocity * delta;
	var motion_slide_up:Vector3 = motion.slide(up_direction);
	var prev_floor_normal:Vector3 = _floor_normal;
	
	var current_frame_moves:Array[Vector3] = []

	_platform_rid = RID()
	_platform_object_id = 0
	_platform_velocity = Vector3()
	_platform_angular_velocity = Vector3()
	_platform_ceiling_velocity = Vector3()
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
		var collision_result:KinematicCollision3D = move_and_collide(motion, false, safe_margin, true, 6)

		if (collision_result):
			var collision_result_collider = collision_result.get_collider()
			var collision_result_collider_id = collision_result.get_collider_id()
			var collision_result_collider_rid = collision_result.get_collider_rid()
			var collision_result_collider_shape = collision_result.get_collider_shape()
			var collision_result_collider_velocity = collision_result.get_collider_velocity()
			var collision_result_collision_count = collision_result.get_collision_count()
			var collision_result_depth = collision_result.get_depth()
			var collision_result_local_shape = collision_result.get_local_shape()
			var collision_result_normal = collision_result.get_normal()
			var collision_result_position = collision_result.get_position()
			var collision_result_remainder = collision_result.get_remainder()
			var collision_result_travel = collision_result.get_travel()
			
			_collision_results.append(collision_result);
#
			var previous_state:CollisionState = _collision_state;
#
			var result_state:CollisionState = CollisionState.new()
			_set_collision_direction(collision_result, result_state, CollisionState.new(true,true,true))
			
			#On the first slide, check if we're on a step
			if first_slide and _collision_state.wall and !_collision_state.ceiling:
				#Test up step height
				var step_up_test_result = KinematicCollision3D.new()
				var step_up_motion = up_direction * max_step_height
				var step_up_test_collided = test_move(global_transform, step_up_motion, step_up_test_result, safe_margin)
				
				var actual_step_up_height:Vector3
				#if collision only test horizontal from travel distance
				if step_up_test_collided:
					actual_step_up_height = step_up_test_result.get_travel()
				#else test from step height
				else:
					actual_step_up_height = step_up_motion
				
				#test over minimum step width
				var step_over_test_result = KinematicCollision3D.new()
				var step_over_motion = collision_result_remainder.normalized() * min_step_width
				var step_over_source_position = global_transform
				step_over_source_position.origin += actual_step_up_height
				var step_over_test_collided = test_move(step_over_source_position, step_over_motion, step_over_test_result, safe_margin)
				
				#if collision check if wall, if wall, don't move
				if step_over_test_collided:
					var hit_wall = false
					for i in range(step_over_test_result.get_collision_count()):
						var hit_floor = false
						var floor_angle = step_over_test_result.get_angle(i, up_direction)
						if floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
							hit_floor = true
						var hit_ceiling = false
						var ceiling_angle = step_over_test_result.get_angle(i, -up_direction)
						if ceiling_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
							hit_ceiling = true
						if not hit_ceiling and not hit_floor:
							hit_wall = true
					
					if !hit_wall:
						global_transform.origin += actual_step_up_height + step_over_motion
						break
					pass
				#else move to target position and break
				else:
					global_transform.origin += actual_step_up_height + step_over_motion
					break
				pass

			# If we hit a ceiling platform, we set the vertical velocity to at least the platform one.
			if _collision_state.ceiling and _platform_ceiling_velocity != Vector3.ZERO and _platform_ceiling_velocity.dot(up_direction) < 0:
				# If ceiling sliding is on, only apply when the ceiling is flat or when the motion is upward.
				if not slide_on_ceiling or motion.dot(up_direction) < 0 or (_ceiling_normal + up_direction).length() < 0.01:
					apply_ceiling_velocity = true
					var ceiling_vertical_velocity: Vector3 = up_direction * up_direction.dot(_platform_ceiling_velocity)
					var motion_vertical_velocity: Vector3 = up_direction * up_direction.dot(velocity)
					if motion_vertical_velocity.dot(up_direction) > 0 or ceiling_vertical_velocity.length_squared() > motion_vertical_velocity.length_squared():
						velocity = ceiling_vertical_velocity + velocity.slide(up_direction)

			if _collision_state.floor and floor_stop_on_slope and (velocity.normalized() + up_direction).length() < 0.01:
				var gt: Transform3D = get_global_transform()
				if collision_result_travel.length() <= safe_margin + CMP_EPSILON:
					gt.origin -= collision_result_travel
				set_global_transform(gt)
				velocity = Vector3.ZERO
				motion = Vector3.ZERO
				_last_motion = Vector3.ZERO
				break

			if collision_result_remainder.is_equal_approx(Vector3.ZERO):
				motion = Vector3.ZERO
				break

			#Apply regular sliding by default.
			var apply_default_sliding: bool = true
			var result_travel:Vector3 = Vector3()
			#Wall collision checks.
			if (result_state.wall && (motion_slide_up.dot(_wall_normal) <= 0)):
				#Move on floor only checks.
				if (floor_block_on_wall):
					#Needs horizontal motion from current motion instead of motion_slide_up
					#to properly test the angle and avoid standing on slopes
					var horizontal_motion:Vector3 = motion.slide(up_direction)
					var horizontal_normal:Vector3 = _wall_normal.slide(up_direction).normalized()
					var motion_angle:float = abs(acos(-horizontal_normal.dot(horizontal_motion.normalized())))
#
					#Avoid to move forward on a wall if floor_block_on_wall is true.
					#Applies only when the motion angle is under 90 degrees,
					#in order to avoid blocking lateral motion along a wall.
					if (motion_angle < .5 * PI):
						apply_default_sliding = false
						if (was_on_floor && !vel_dir_facing_up):
							#Cancel the motion.
							var gt:Transform3D = global_transform
							var travel_total:float = collision_result_travel.length()
							var cancel_dist_max:float = min(0.1, safe_margin * 20)
							if (travel_total <= safe_margin + CMP_EPSILON):
								gt.origin -= collision_result_travel
								#Cancel for constant speed computation.
								result_travel = Vector3()
							#If the movement is large the body can be prevented from reaching the walls.
							elif (travel_total < cancel_dist_max):
								gt.origin -= collision_result_travel.slide(up_direction)
								#Keep remaining motion in sync with amount canceled.
								motion = motion.slide(up_direction)
								result_travel = Vector3()
							else:
								#Travel is too high to be safely canceled, we take it into account.
								result_travel = collision_result_travel.slide(up_direction)
								motion = motion.normalized() * collision_result_travel.length()
							
							set_global_transform(gt);
							#Determines if you are on the ground, and limits the possibility of climbing on the walls because of the approximations.
							_snap_on_floor(true, false);
						else:
							#If the movement is not canceled we only keep the remaining.
							motion = collision_result_remainder

						#Apply slide on forward in order to allow only lateral motion on next step.
						var forward:Vector3 = _wall_normal.slide(up_direction).normalized()
						motion = motion.slide(forward)

						#Scales the horizontal velocity according to the wall slope.
						if (vel_dir_facing_up):
							var slide_motion:Vector3 = velocity.slide(collision_result_normal)
							#Keeps the vertical motion from velocity and add the horizontal motion of the projection.
							velocity = up_direction * up_direction.dot(velocity) + slide_motion.slide(up_direction)
						else:
							velocity = velocity.slide(forward)

						#Allow only lateral motion along previous floor when already on floor.
						#Fixes slowing down when moving in diagonal against an inclined wall.
						if (was_on_floor && !vel_dir_facing_up && (motion.dot(up_direction) > 0.0)):
							#Slide along the corner between the wall and previous floor.
							var floor_side:Vector3 = prev_floor_normal.cross(_wall_normal)
							if (floor_side != Vector3()):
								motion = floor_side * motion.dot(floor_side)

						#Stop all motion when a second wall is hit (unless sliding down or jumping),
						#in order to avoid jittering in corner cases.
						var stop_all_motion:bool = previous_state.wall && !vel_dir_facing_up

						#Allow sliding when the body falls.
						if (!_collision_state.floor && motion.dot(up_direction) < 0):
							var slide_motion:Vector3 = motion.slide(_wall_normal)
							#Test again to allow sliding only if the result goes downwards.
							#Fixes jittering issues at the bottom of inclined walls.
							if (slide_motion.dot(up_direction) < 0):
								stop_all_motion = false
								motion = slide_motion

						if (stop_all_motion):
							motion = Vector3()
							velocity = Vector3()

				#Stop horizontal motion when under wall slide threshold.
				if (was_on_floor && (wall_min_slide_angle > 0.0) && result_state.wall):
					var horizontal_normal:Vector3 = _wall_normal.slide(up_direction).normalized()
					var motion_angle:float = abs(acos(-horizontal_normal.dot(motion_slide_up.normalized())))
					if (motion_angle < wall_min_slide_angle):
						motion = up_direction * motion.dot(up_direction)
						velocity = up_direction * velocity.dot(up_direction)
#
						apply_default_sliding = false

			if apply_default_sliding:
				#Regular sliding, the last part of the test handle the case when you don't want to slide on the ceiling.
				if (sliding_enabled or not _collision_state.floor) and (not _collision_state.ceiling or slide_on_ceiling or not vel_dir_facing_up) and not apply_ceiling_velocity:
					#var collision = result.collisions[0]
					var collision_normal:Vector3 = collision_result_normal
					var slide_motion = collision_result_remainder.slide(collision_normal)
					if _collision_state.floor and not _collision_state.wall and not motion_slide_up.is_equal_approx(Vector3.ZERO):
						# Slide using the intersection between the motion plane and the floor plane,
						# in order to keep the direction intact.
						var motion_length = slide_motion.length()
						slide_motion = up_direction.cross(collision_result_remainder).cross(_floor_normal)

						# Keep the length from default slide to change speed in slopes by default,
						# when constant speed is not enabled.
						slide_motion = slide_motion.normalized() * motion_length

					if slide_motion.dot(velocity) > 0.0:
						motion = slide_motion
					else:
						motion = Vector3.ZERO

					if slide_on_ceiling and result_state.ceiling:
						# Apply slide only in the direction of the input motion, otherwise just stop to avoid jittering when moving against a wall.
						if vel_dir_facing_up:
							velocity = velocity.slide(collision_normal)
						else:
							# Avoid acceleration in slope when falling.
							velocity = up_direction * up_direction.dot(velocity)
				else:
					motion = collision_result_remainder
					if result_state.ceiling and not slide_on_ceiling and vel_dir_facing_up:
						velocity = velocity.slide(up_direction)
						motion = motion.slide(up_direction)

			total_travel += result_travel

			#Apply Constant Speed.
			if (was_on_floor && floor_constant_speed && can_apply_constant_speed && _collision_state.floor && !motion.is_zero_approx()):
				var travel_slide_up:Vector3 = total_travel.slide(up_direction)
				motion = motion.normalized() * max(0, (motion_slide_up.length() - travel_slide_up.length()));

		#When you move forward in a downward slope you don’t collide because you will be in the air.
		#This test ensures that constant speed is applied, only if the player is still on the ground after the snap is applied.
		elif (floor_constant_speed && first_slide && _on_floor_if_snapped(was_on_floor, vel_dir_facing_up)):
			can_apply_constant_speed = false
			sliding_enabled = true
			var gt:Transform3D = global_transform
			
			#gt.origin = gt.origin - result.get_travel
			set_global_transform(gt);
#
			#Slide using the intersection between the motion plane and the floor plane,
			#in order to keep the direction intact.
			var motion_slide_norm:Vector3 = up_direction.cross(motion).cross(prev_floor_normal)
			motion_slide_norm = motion_slide_norm.normalized()
#
			motion = motion_slide_norm * (motion_slide_up.length())
			collision_result = KinematicCollision3D.new()

		if (!collision_result || motion.is_zero_approx()):
			break

		can_apply_constant_speed = !can_apply_constant_speed && !sliding_enabled
		sliding_enabled = true
		first_slide = false

	_snap_on_floor(was_on_floor, vel_dir_facing_up)

	#Reset the gravity accumulation when touching the ground.
	if (_collision_state.floor && !vel_dir_facing_up):
		velocity = velocity.slide(up_direction)



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
		var result:KinematicCollision3D = move_and_collide(motion, false, safe_margin, true)

		_last_motion = result.get_travel()

		if result:
			_collision_results.push_back(result)

			var result_state = {} # Placeholder for your specific collision state handling
			_set_collision_direction(result, result_state, CollisionState.new(true,true,true))

			if result.remainder.is_equal_approx(Vector3.ZERO):
				motion = Vector3.ZERO
				break

			if wall_min_slide_angle != 0 and acos(_wall_normal.dot(-velocity.normalized())) < wall_min_slide_angle + FLOOR_ANGLE_THRESHOLD:
				motion = Vector3.ZERO
				if result.get_travel().length() < safe_margin + CMP_EPSILON:
					var gt: Transform3D = get_global_transform()
					gt.origin -= result.get_travel()
					set_global_transform(gt)
			elif first_slide:
				var motion_slide_norm: Vector3 = result.remainder.slide(_wall_normal).normalized()
				motion = motion_slide_norm * (motion.length() - result.get_travel().length())
			else:
				motion = result.remainder.slide(_wall_normal)

			if motion.dot(velocity) <= 0.0:
				motion = Vector3.ZERO

		if not result or motion.is_equal_approx(Vector3.ZERO):
			break

		first_slide = false


func _set_collision_direction(p_result:KinematicCollision3D, r_state:CollisionState, p_apply_state:CollisionState):
	r_state.state = 0

	var wall_depth: float = -1.0
	var floor_depth: float = -1.0

	var was_on_wall: bool = _collision_state.wall
	var prev_wall_normal: Vector3 = _wall_normal
	var wall_collision_count: int = 0
	var combined_wall_normal: Vector3 = Vector3()
	var tmp_wall_col: Vector3 = Vector3() # Avoid duplicate on average calculation.
	var p_result_collusion_count = p_result.get_collision_count()

	for i in range(p_result.get_collision_count() - 1, -1, -1):
		
		var collision_normal = p_result.get_normal(i)
		var collision_depth = p_result.get_depth()

		var floor_angle = p_result.get_angle(i, up_direction)
		var ceiling_angle = p_result.get_angle(i, -up_direction)
		if motion_mode == MotionMode.MOTION_MODE_GROUNDED:
			# Check if any collision is floor.
			if floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
				r_state.floor = true
				if p_apply_state.floor and collision_depth > floor_depth:
					_collision_state.floor = true
					_floor_normal = collision_normal
					floor_depth = collision_depth
					_set_platform_data(p_result, i)
				continue

			# Check if any collision is ceiling.
			if ceiling_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
				r_state.ceiling = true
				if p_apply_state.ceiling:
					_platform_ceiling_velocity = p_result.get_collider_velocity(i)
					_ceiling_normal = collision_normal
					_collision_state.ceiling = true
				continue

		# Collision is wall by default.
		r_state.wall = true

		if p_apply_state.wall and collision_depth > wall_depth:
			_collision_state.wall = true
			wall_depth = collision_depth
			_wall_normal = collision_normal

			# Don't apply wall velocity when the collider is not a CharacterBody3D.
			if not instance_from_id(p_result.get_collider_id(i)) is CharacterBody3D:
				_set_platform_data(p_result, i)

		# Collect normal for calculating average.
		if not collision_normal.is_equal_approx(tmp_wall_col):
			tmp_wall_col = collision_normal
			combined_wall_normal += collision_normal
			wall_collision_count += 1

	if r_state.wall:
		if wall_collision_count > 1 and not r_state.floor:
			# Check if wall normals cancel out to floor support.
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

func _on_floor_if_snapped(p_was_on_floor: bool, p_vel_dir_facing_up: bool) -> bool:
	if up_direction == Vector3.ZERO or _collision_state.floor or not p_was_on_floor or p_vel_dir_facing_up:
		return false

	# Snap by at least collision margin to keep floor state consistent.
	var length: float = max(floor_snap_length, safe_margin)

	# Also report collisions generated only from recovery.
	var result = KinematicCollision3D.new()
	if test_move(global_transform, -up_direction * length, result,safe_margin,true, 4):
		var result_state = {} # Adjust this based on how you manage collision states in GDScript
		# Don't apply direction for any type. You need to adapt this part to your GDScript context.
		_set_collision_direction(result, result_state, CollisionState.new(false,false,false))

		return result_state.floor

	return false


func _set_platform_data(p_collision:KinematicCollision3D, index:int):
	_platform_rid = p_collision.get_collider_rid(index)
	var body_state = PhysicsServer3D.body_get_direct_state(_platform_rid)
	_platform_object_id = p_collision.get_collider_id(index)
	_platform_velocity = p_collision.get_collider_velocity(index)
	_platform_angular_velocity = body_state.angular_velocity
	_platform_layer = PhysicsServer3D.body_get_collision_layer(_platform_rid)

func _snap_on_floor(p_was_on_floor: bool, p_vel_dir_facing_up: bool) -> void:
	if _collision_state.floor or not p_was_on_floor or p_vel_dir_facing_up:
		return

	apply_floor_snap()

func apply_floor_snap():
	if _collision_state.floor:
		return

	# Snap by at least collision margin to keep floor state consistent.
	var length: float = max(floor_snap_length, safe_margin)

	var result = KinematicCollision3D.new()
	if test_move(global_transform, -up_direction * length, result, safe_margin, true, 4):
		var result_state = CollisionState.new(false,false,false) # Initialize your collision state structure appropriately
		# Apply direction for floor only. Adjust this method call to match your GDScript implementation.
		_set_collision_direction(result, result_state, CollisionState.new(true, true, true))

		if result_state.floor:
			if floor_stop_on_slope:
				# Move and collide may stray the object a bit because of pre un-stucking,
				# so only ensure that motion happens on floor direction in this case.
				if result.get_travel().length() > safe_margin:
					result.travel = up_direction * up_direction.dot(result.get_travel())
				else:
					result.travel = Vector3.ZERO

			global_position += result.get_travel()


class CollisionState:
	var state:int = 0
	var floor:bool = false
	var wall:bool = false
	var ceiling:bool = false
	
	func _init(_floor:bool = false, _wall:bool = false, _ceiling:bool = false) -> void:
		floor = _floor
		wall = _wall
		ceiling = _ceiling
