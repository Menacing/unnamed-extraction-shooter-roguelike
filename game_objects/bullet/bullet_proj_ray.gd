extends PhysicsBody3D
class_name BulletProjRay

@export var initial_speed = 700.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@export var k: float = 0.001289
@export var moa:float
var shot_origin:Vector3
var firer:Node3D

var current_speed: float
var current_damage: float
var elapsed_time: float = 0.0

@onready var col_shape:CollisionShape3D = $CollisionShape3D
@onready var mesh_inst:MeshInstance3D = $MeshInstance3D
@onready var bullet_radius:float = $CollisionShape3D.shape.radius
var continue_process:bool = true
@onready var despawn_timer:Timer = $DespawnTimer
var collision_exclusions:Array[RID] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	current_speed = initial_speed
	current_damage = initial_damage
	Helpers.random_angle_deviation_moa(self, moa,moa)
	shot_origin = self.global_position
	self.add_collision_exception_with(self)
	collision_exclusions.append(self.get_rid())
#	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	elapsed_time += delta
	if continue_process:
		do_raycast_movement(delta)

func raycast_to_dest(source_global_pos:Vector3,destination_global_pos:Vector3) -> Dictionary:
	var space_state = self.get_world_3d().direct_space_state
	if space_state:
		var query = PhysicsRayQueryParameters3D.create(source_global_pos, destination_global_pos)
		query.collide_with_areas = true
		query.collision_mask = self.collision_mask
		query.exclude = collision_exclusions
		var result = space_state.intersect_ray(query)
		return result
	return {}

func do_raycast_movement(delta:float):
	#set up initial value and destination
	var motion_dir = -delta * current_speed * transform.basis.z
	var travel_vector:Vector3 = Vector3() 
	var remaining_delta:float = delta
	var start_source_destination:Vector3 = self.global_position
	var start_target_destination:Vector3 = self.global_position + motion_dir
	var remaining_distance:float = (start_target_destination - start_source_destination).length()
	var source_destination:Vector3 = start_source_destination
	var target_destination:Vector3 = start_target_destination
	#While we have distance to cover, loop
	while remaining_distance > 0.0001:
		#Raycast to target location
		var raycast_result = raycast_to_dest(source_destination,target_destination)
		#If we didn't hit anything, add the travel distance and break
		if raycast_result.is_empty():
			travel_vector += (target_destination - source_destination)
			remaining_distance = 0.0
		#else, handle collision
		else:
			#Add traveled distance to collision location
			travel_vector += (raycast_result.position - source_destination)
			#if collider has an onhit function, call it and handle result
			var collider = raycast_result.collider
			if collider and collider.has_method("_on_hit"):
				var col = CollisionInformation.map_from_ray_result(raycast_result)
				#call on hit
				var pen_ratio = collider._on_hit(current_damage, pen_rating, col,shot_origin)
				#handle speed and damage reduction
				var new_speed = current_speed * pen_ratio
				
				#calculate new target and delta
				var distance_went:float = (raycast_result.position - source_destination).length()
				var time_took:float = distance_went * remaining_delta / (target_destination - source_destination).length()
				remaining_delta -= time_took
				current_damage = pow(new_speed/current_speed,2) * current_damage
				current_speed = new_speed
				target_destination = raycast_result.position + (-remaining_delta * current_speed * transform.basis.z)
			elif collider is Area3D:
				collider.body_entered.emit(self)
			else:
				startDespawn()
			if collider is CollisionObject3D:
				self.add_collision_exception_with(collider)
			collision_exclusions.append(raycast_result.rid)
			
			#set current position to collision location
			source_destination = raycast_result.position
			#set remaining distance to cover
			remaining_distance = (target_destination - source_destination).length()
			pass
			
	var col:KinematicCollision3D = move_and_collide(travel_vector,false,0.001,true)
	#if col:
		#print("something went wrong, col should always be null doing it this way")
	var new_speed = (current_speed/ (1+k*delta*current_speed))
	current_damage = pow(new_speed/current_speed,2) * current_damage
	current_speed = new_speed
	if is_nan(current_damage) or current_damage / initial_damage < .25:
		print("bullet peetered out after %s" % elapsed_time)
		startDespawn()


func startDespawn():
	continue_process = false
	col_shape.disabled = true
	mesh_inst.visible = false
	despawn_timer.start()


func _on_despawn_timer_timeout():
	queue_free()
