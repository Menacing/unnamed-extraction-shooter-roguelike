extends CharacterBody3D
class_name Enemy

var fire_target:Node3D
var move_target:Node3D
@export var move_target_distance:float = 1.0
@export var patrol_poi_group:String = "PatrolPOI"
@export var nav_agent:NavigationAgent3D
@export var weapon_rotation_speed:float = 2.0
@export var body_rotation_speed:float = 1.0
@export var move_speed:float = 3.0
@export var head_node:Node3D
@export var gun_node:Gun
@export var vert_moa:float = 600
@export var hor_moa:float = 600
@export var los_location_ratio:float = 0.6
@export var detection_radius:Area3D
@export var ballistic_detection_radius:Area3D
var target_player:Player

func _ready():
	if detection_radius:
		detection_radius.area_entered.connect(_on_body_entered_detection_radius)
		detection_radius.area_exited.connect(_on_body_exited_detection_radius)
	if ballistic_detection_radius:
		ballistic_detection_radius.area_entered.connect(_on_body_entered_ballistic_detection_radius)
		ballistic_detection_radius.area_exited.connect(_on_body_exited_ballistic_detection_radius)
		
	if nav_agent:
		nav_agent.velocity_computed.connect(_on_velocity_computed)
	pass
	
func _on_body_entered_detection_radius(body:Node3D):
	if body is Player:
		target_player = body
	
func _on_body_exited_detection_radius(body:Node3D):
	if body is Player:
		target_player = null
	
func _on_body_entered_ballistic_detection_radius(body:Node3D):
	if body is BulletProjRay:
		if body.firer and body.firer is Player:
			target_player = body.firer
	pass
	
func _on_body_exited_ballistic_detection_radius(body:Node3D):
	pass
	
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func has_fire_target() -> bool:
	if fire_target:
		return true
	else:
		return false

func has_move_target() -> bool:
	if move_target:
		return true
	else:
		return false

func has_target_player() -> bool:
	if target_player:
		return true
	else:
		return false
		
func has_los_to_player() -> bool:
	if target_player:
		
		var exclusions:Array[RID] = Helpers.get_all_collision_object_3d_recursive(self) + Helpers.get_all_collision_object_3d_recursive(target_player)
		
		var los_result = Helpers.los_to_point(head_node,target_player.los_check_locations,.6,exclusions)
		return los_result
	else:
		return false

func is_near_move_target() -> bool:
	if has_move_target():
		var dis = Helpers.distance_between(self, move_target)
		if dis <= move_target_distance:
			return true
	
	return false

func find_new_patrol_poi_move_target() -> bool:
	var pois = get_tree().get_nodes_in_group(patrol_poi_group)
	pois.shuffle()
	
	for poi in pois:
		#if POI is not an Area3D, skip
		if not poi is Area3D:
			break
		#If we don't currently have a target, take the first one
		if !move_target:
			move_target = poi
			return true
		#If the current target is the poi, skip it
		if poi == move_target:
			break
		else:
			move_target = poi
			return true
		#else take the poi
	return false

func set_new_path():
	if move_target and nav_agent:
		nav_agent.set_target_position(move_target.global_position)
	
func nav_agent_move():
	if nav_agent.is_navigation_finished():
		return
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_target_velocity = (next_location - current_location).normalized() * move_speed
	var new_velocity = velocity.move_toward(new_target_velocity, .25)
	Helpers.slow_rotate_to_point_flat(self, next_location, body_rotation_speed, get_physics_process_delta_time())
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func slow_weapon_turn():
	var delta = get_physics_process_delta_time()

	Helpers.slow_rotate_to_point(head_node, fire_target.global_transform.origin, weapon_rotation_speed, delta)
	Helpers.slow_rotate_to_point(gun_node, fire_target.global_transform.origin, weapon_rotation_speed, delta)

func fire_weapon():
	Helpers.random_angle_deviation_moa(gun_node,vert_moa,hor_moa)
	gun_node.fireGun()
