extends RayCast3D
class_name RaycastBullet

@export var range:float = 1000.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@onready var shot_origin:Vector3 = self.global_position
var firer:Node3D


var continue_process:bool = true
@onready var despawn_timer:Timer = $DespawnTimer
@onready var attack_component:AttackComponent = %AttackComponent


func _physics_process(delta):
	if continue_process:
		do_raycast_movement()

func raycast_to_dest(new_target_position:Vector3):
	self.target_position = new_target_position
	self.force_raycast_update()

func do_raycast_movement():
	#set up initial value and destination
	var motion_dir = range * Vector3.FORWARD
	#While we have distance to cover, loop
	while motion_dir.length() > 0.0001:
		var new_pos_g:Vector3
		var damage_factor = 1.0
		#Raycast to target location
		raycast_to_dest(motion_dir)
		
		#Handle collision
		#If we didn't hit anything, move the full distance, and stop
		if !self.is_colliding():
			new_pos_g =  self.to_global(motion_dir)
			motion_dir = Vector3.ZERO
		else:
			var collider = self.get_collider()
			#if we hit a collider, check for a damage component
			if collider:
				var damage_component:DamageComponent = Helpers.get_component_of_type(collider, DamageComponent)
				if damage_component:
					#apply damage
					attack_component.attack_normal = self.get_collision_normal()
					attack_component.attack_position = self.get_collision_point()
					attack_component.damage = initial_damage * damage_factor
					attack_component.armor_penetration_rating = pen_rating
					var attack_result:AttackResult = damage_component.hit(attack_component)
					#update speed based on result
					damage_factor = damage_factor * attack_result.percent_penetrated
					
					if damage_factor <= 0.1:
						motion_dir = Vector3.ZERO
				
				#else if we hit an area3D, let them know and adjust speed ballistically
				elif collider is Area3D:
					collider.body_entered.emit(self)
				
				#in both cases move to collision point for recalculation
				new_pos_g = self.get_collision_point()
				var distance_travelled:float = (new_pos_g - self.global_position).length()

				motion_dir = (range - distance_travelled) * Vector3.FORWARD
			else:
				printerr("Hit something WEIRD")
				motion_dir = Vector3.ZERO
				startDespawn()
				
			self.add_exception_rid(self.get_collider_rid())
		
		#adjust speed and damage
		#set new global position
		self.global_position = new_pos_g

	startDespawn()
	continue_process = false


func startDespawn():
	continue_process = false
	despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
