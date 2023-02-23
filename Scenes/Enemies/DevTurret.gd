extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $Head as Node3D
@export var gun_scene: PackedScene
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0
var run_speed = 3
var accel = 3
var player = null
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var repath_timer:Timer = $RepathTimer

# Called when the node enters the scene tree for the first time.
func _ready():
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
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(self.global_transform.origin)

func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_position(movement_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity.y -= gravity * delta	
	if nav_agent.is_navigation_finished():
		return
	if player:
		look_at(player.global_transform.origin, Vector3.UP)	

	var current_agent_position : Vector3 = global_transform.origin
	var next_path_position : Vector3 = nav_agent.get_next_path_position()

	var new_velocity : Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * run_speed
#	new_velocity.y = velocity.y

	set_velocity(new_velocity)
	move_and_slide()


func _on_fire_timer_timeout():
	gun.fireGun()

func _on_took_damage(damage:float):
	health-=damage
	if health < 0:
		print("I am dead")
		queue_free()

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.get_position()])
	_on_took_damage(damage)
	return pen_ratio


func _on_detect_radius_body_entered(body):
	if body is Player:
		player = body
		set_movement_target(player.global_transform.origin)
		repath_timer.start()


func _on_detect_radius_body_exited(body):
	if body is Player:
		player = null
		set_movement_target(self.global_transform.origin)
		repath_timer.stop()


func _on_repath_timer_timeout():
	if player:
		set_movement_target(player.global_transform.origin)
