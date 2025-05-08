extends RayCast3D
class_name RaycastBullet

@export var range:float = 1000.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@onready var shot_origin:Vector3 = self.global_position
var firer:Node3D
var _beam_endpoint:Vector3

var continue_process:bool = true
@onready var despawn_timer:Timer = $DespawnTimer
@onready var attack_component:AttackComponent = %AttackComponent
@onready var beam_mesh: MeshInstance3D = $BeamMesh


func _physics_process(delta):
	if continue_process:
		do_raycast_movement()
		
	
func update_beam():
	var local_beam_endpoint = to_local(_beam_endpoint)
	beam_mesh.mesh.height = abs(local_beam_endpoint.z)
	beam_mesh.position.z = -abs(local_beam_endpoint.z/2)

func do_raycast_movement():
	#set up initial value and destination
	var damage_factor = 1.0
	#Raycast to target location
	self.target_position = range * Vector3.FORWARD
	var beam_stopped = false

	
	while not beam_stopped:
		self.force_raycast_update()
		#Handle collision
		#If we didn't hit anything, move the full distance, and stop
		if self.is_colliding():
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
						beam_stopped = true
						_beam_endpoint = self.get_collision_point()
				
				#else if we hit an area3D, let them know and adjust speed ballistically
				elif collider is Area3D:
					collider.body_entered.emit(self)
				
				#in both cases add collision exception
				self.add_exception_rid(self.get_collider_rid())
			else:
				printerr("Hit something WEIRD")
				beam_stopped = true
				_beam_endpoint = self.get_collision_point()
				startDespawn()
				
			self.add_exception_rid(self.get_collider_rid())
			
		else:
			beam_stopped = true
			_beam_endpoint = to_global(self.target_position)

	startDespawn()
	continue_process = false
	update_beam()
	


func startDespawn():
	continue_process = false
	despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
