extends RayCast3D
class_name IterativeRaycastBullet

@export var initial_speed = 700.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@export var k: float = 0.001289
@export var moa:float
@onready var shot_origin:Vector3 = self.global_position
var firer:Node3D

var current_speed: float
var current_damage: float
var elapsed_time: float = 0.0

var continue_process:bool = true
@onready var despawn_timer:Timer = $DespawnTimer
@onready var attack_component:AttackComponent = %AttackComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	current_speed = initial_speed
	attack_component.damage = initial_damage
	Helpers.random_angle_deviation_moa(self, moa,moa)

func _physics_process(delta):
	elapsed_time += delta
	if continue_process:
		do_raycast_movement(delta)

func raycast_to_dest(source_global_pos:Vector3,destination_global_pos:Vector3):
	self.global_position = source_global_pos
	self.target_position = self.to_local(destination_global_pos)
	self.force_raycast_update()

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
		raycast_to_dest(source_destination,target_destination)
		#If we didn't hit anything, add the travel distance and break
		if !self.is_colliding():
			travel_vector += (target_destination - source_destination)
			remaining_distance = 0.0
		#else, handle collision
		else:
			#Add traveled distance to collision location
			travel_vector += (self.get_collision_point() - source_destination)
			#if collider has an onhit function, call it and handle result
			var collider = self.get_collider()
			if collider:
				var damage_component:DamageComponent = Helpers.get_component_of_type(collider, DamageComponent)
				if damage_component:
					attack_component.attack_normal = self.get_collision_normal()
					attack_component.attack_position = self.get_collision_point()
					var attack_result:AttackResult = damage_component.hit(attack_component)
					
					var new_speed = current_speed * attack_result.percent_penetrated
				
					#calculate new target and delta
					var distance_went:float = (self.get_collision_point() - source_destination).length()
					var time_took:float = distance_went * remaining_delta / (target_destination - source_destination).length()
					remaining_delta -= time_took
					current_damage = pow(new_speed/current_speed,2) * current_damage
					current_speed = new_speed
					target_destination = self.get_collision_point() + (-remaining_delta * current_speed * transform.basis.z)
				elif collider is Area3D:
					collider.body_entered.emit(self)
			else:
				startDespawn()
				
			self.add_exception_rid(self.get_collider_rid())
			
			#set current position to collision location
			source_destination = self.get_collision_point()
			#set remaining distance to cover
			remaining_distance = (target_destination - source_destination).length()
			pass
			
	var new_speed = (current_speed/ (1+k*delta*current_speed))
	current_damage = pow(new_speed/current_speed,2) * current_damage
	current_speed = new_speed
	if is_nan(current_damage) or current_damage / initial_damage < .25:
		print("bullet peetered out after %s" % elapsed_time)
		startDespawn()


func startDespawn():
	continue_process = false
	despawn_timer.start()


func _on_despawn_timer_timeout():
	queue_free()
