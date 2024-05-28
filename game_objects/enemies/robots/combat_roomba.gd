extends Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head" as Node3D
@export var gun_scene: PackedScene
@export var hit_effect: PackedScene = load("res://game_objects/effects/bullet_hit_sparks.tscn")
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0
var accel = 3
var turret_rotation:float = 2.0

var player:Player
@onready var exclusions:Array[RID]
var self_exclusions:Array[RID]
var player_aimpoint:Node3D:
	get:
		if player:
			return player.center_mass
		else:
			return null
var _last_los_check_result:bool = false
var last_los_check_result:bool:
	get:
		return _last_los_check_result
	set(value):
		if value != _last_los_check_result:
			_last_los_check_result = value
			los_changed(value)
var reaction_timed_out:bool = false
var can_react:bool:
	get:
		return last_los_check_result and reaction_timed_out
@onready var repath_timer:Timer = $RepathTimer
@onready var reaction_timer:Timer = $ReactionTimer
@onready var skeleton:Skeleton3D = $"combat-roomba/Armature/Skeleton3D"
@onready var physical_bone:PhysicalBone3D = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone"
var alive = true
var last_damage_normal:Vector3
var last_damage:float



# Called when the node enters the scene tree for the first time.
func _ready():
	self_exclusions = Helpers.get_all_collision_object_3d_recursive(self)
	exclusions = self_exclusions
	if gun_scene: 
		gun = gun_scene.instantiate()
		gun.start_highlighted = false
		gun.picked_up()
		#TODO: Pull these from the packed scene instead of being hardcoded
		gun._gun_stats.magazine_size = 30000
		gun.current_magazine_size = 30000
		hf_pos = -gun.get_hip_fire_anchor()

		gun.position = hf_pos
		head.add_child(gun)
		gun.firer = self



func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta):
	if alive:
		last_los_check_result = has_los_to_player()
		if can_react:
			Helpers.slow_rotate_to_point(head, player_aimpoint.global_transform.origin, turret_rotation, delta)
			Helpers.slow_rotate_to_point(gun, player_aimpoint.global_transform.origin, turret_rotation, delta)




func _on_fire_timer_timeout():
	if can_react and alive and gun:
		Helpers.random_angle_deviation_moa(gun,vert_moa,hor_moa)
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
	$CollisionShape3D.disabled = true
	$CollisionShape3D2.disabled = true
	$CollisionShape3D3.disabled = true
	$"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head/SpotLight3D".visible = false
#	var inv_node = inv.instantiate()
#	inv_node.container_size = container_size
#	Events.create_inventory.emit(inv_node,self.name)

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.position])
	last_damage_normal = col.normal
	last_damage = damage
	_on_took_damage(damage)
	var normal = col.normal
	
	if hit_effect:
		var hit_inst = hit_effect.instantiate() as Node3D
		hit_inst.set_as_top_level(true)
		get_parent().add_child(hit_inst)
		hit_inst.global_transform.origin = position
		hit_inst.look_at(normal+position,Vector3.UP)
	
	return pen_ratio

func has_attack_target() -> bool:
	if player and can_react:
		return true
	else:
		return false

func _on_detect_radius_body_entered(body):
	if body is Player:
		player = body
		var player_collider_rids = Helpers.get_all_collision_object_3d_recursive(player)
		exclusions.append_array(player_collider_rids)
		repath_timer.start()
		set_new_path()


func _on_detect_radius_body_exited(body):
	if body is Player:
		player = null
		exclusions = self_exclusions
		set_movement_target(self.global_transform.origin)
		repath_timer.stop()


func _on_repath_timer_timeout():
	set_new_path()

func has_los_to_player() -> bool:
	if player:
		var los_result = Helpers.los_to_point(head,player.los_check_locations,.6,exclusions)
		return los_result
	else:
		return false
		
func los_changed(new_los:bool):
	if new_los:
		if reaction_timer.is_stopped():
			reaction_timer.start()
	else:
		if reaction_timer.is_stopped():
			reaction_timed_out = false


func _on_reaction_timer_timeout():
	reaction_timed_out = true

var target_patrol_poi:Area3D

func is_in_target_patrol_poi() -> bool:
	var result = false
	if target_patrol_poi:
		result = target_patrol_poi.overlaps_body(self)
	return result


