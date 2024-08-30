extends RayCast3D
class_name IterativeRaycastBullet

@export var initial_speed = 700.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@export var k: float = 0.001289
@onready var shot_origin:Vector3 = self.global_position
var firer:Node3D

var current_speed: float
var current_damage: float
var elapsed_time: float = 0.0

var continue_process:bool = true
@onready var despawn_timer:Timer = $DespawnTimer
@onready var attack_component:AttackComponent = %AttackComponent


func _physics_process(delta):
	elapsed_time += delta
	if continue_process:
		do_raycast_movement(delta)

func raycast_to_dest(new_target_position:Vector3):
	self.target_position = new_target_position
	self.force_raycast_update()

func do_raycast_movement(delta:float):
	#set up initial value and destination
	var motion_dir = delta * current_speed * Vector3.FORWARD
	var remaining_delta = delta
	#While we have distance to cover, loop
	while motion_dir.length() > 0.0001:
		var new_speed:float
		var new_pos_g:Vector3
		#Raycast to target location
		raycast_to_dest(motion_dir)
		
		#Handle collision
		#If we didn't hit anything, move the full distance, and stop
		if !self.is_colliding():
			new_pos_g =  self.to_global(motion_dir)
			motion_dir = Vector3.ZERO
			new_speed = (current_speed/ (1+k*remaining_delta*current_speed))
			remaining_delta = 0.0
		else:
			var collider = self.get_collider()
			#if we hit a collider, check for a damage component
			if collider:
				var damage_component:DamageComponent = Helpers.get_component_of_type(collider, DamageComponent)
				if damage_component:
					#apply damage
					attack_component.attack_normal = self.get_collision_normal()
					attack_component.attack_position = self.get_collision_point()
					attack_component.damage = current_damage
					attack_component.armor_penetration_rating = pen_rating
					var attack_result:AttackResult = damage_component.hit(attack_component)
					#update speed based on result
					new_speed = current_speed * attack_result.percent_penetrated
				
				#else if we hit an area3D, let them know and adjust speed ballistically
				elif collider is Area3D:
					new_speed = (current_speed/ (1+k*remaining_delta*current_speed))
					collider.body_entered.emit(self)
				
				#in both cases move to collision point for recalculation
				new_pos_g = self.get_collision_point()
				var distance_travelled:float = (new_pos_g - self.global_position).length()
				var time_taken:float = distance_travelled / current_speed
				remaining_delta = remaining_delta - time_taken
				motion_dir = remaining_delta * new_speed * Vector3.FORWARD
			else:
				printerr("Hit something WEIRD")
				motion_dir = Vector3.ZERO
				startDespawn()
				
			self.add_exception_rid(self.get_collider_rid())
		
		#adjust speed and damage
		_adjust_speed(new_speed)
		#set new global position
		self.global_position = new_pos_g


func _adjust_speed(new_speed:float):
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
