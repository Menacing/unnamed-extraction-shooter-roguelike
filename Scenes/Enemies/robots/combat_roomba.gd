extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head" as Node3D
@export var gun_scene: PackedScene
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0
var run_speed = 3
var accel = 3
var player_aimpoint:Node3D = null
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var repath_timer:Timer = $RepathTimer
@onready var skeleton:Skeleton3D = $"combat-roomba/Armature/Skeleton3D"
@onready var physical_bone:PhysicalBone3D = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone"
var alive = true
var last_damage_normal:Vector3
var last_damage:float

# Called when the node enters the scene tree for the first time.
func _ready():
	if gun_scene:
		gun = gun_scene.instantiate()
		var gun_item_comp:ItemComponent = gun.get_node("ItemComponent")
		gun_item_comp.start_highlighted = false
		gun_item_comp.picked_up()
		#TODO: Pull these from the packed scene instead of being hardcoded
		gun.magazineSize = 30000
		gun.magazine= 30000
		hf_pos = -gun.get_node("HipFire").position

		gun.position = hf_pos
		head.add_child(gun)



func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta):
	if alive:
		if player_aimpoint:
			head.look_at(player_aimpoint.global_transform.origin, Vector3.UP)
			gun.look_at(player_aimpoint.global_transform.origin, Vector3.UP)
			
		
		if nav_agent.is_navigation_finished():
			return
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * run_speed
		
		velocity = velocity.move_toward(new_velocity, .25)
		move_and_slide()


func _on_fire_timer_timeout():
	if player_aimpoint and alive and gun:
		gun.fireGun()

func _on_took_damage(damage:float):
	health-=damage
	if health < 0:
		die()
		
func die():
	print("I am dead")
	alive = false
	skeleton.animate_physical_bones = true
	skeleton.physical_bones_start_simulation()
	var damage_vector = last_damage_normal.normalized() * 5
	PhysicsServer3D.body_set_state(physical_bone.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, damage_vector)
	
#	var inv_node = inv.instantiate()
#	inv_node.container_size = container_size
#	Events.create_inventory.emit(inv_node,self.name)

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.get_position()])
	last_damage_normal = col.get_normal()
	last_damage = damage
	_on_took_damage(damage)
	return pen_ratio


func _on_detect_radius_body_entered(body):
	if body is Player:
		player_aimpoint = body.center_mass
		set_movement_target(player_aimpoint.global_transform.origin)
		repath_timer.start()


func _on_detect_radius_body_exited(body):
	if body is Player:
		player_aimpoint = null
		set_movement_target(self.global_transform.origin)
		repath_timer.stop()


func _on_repath_timer_timeout():
	if player_aimpoint:
		set_movement_target(player_aimpoint.global_transform.origin)
