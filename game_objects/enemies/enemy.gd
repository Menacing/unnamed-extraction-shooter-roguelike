extends CharacterBody3D
class_name Enemy

var attack_target:Node3D
var move_target:Node3D
@export var move_target_distance:float = 1.0
@export var patrol_poi_group:String = "PatrolPOI"
@export var nav_agent:NavigationAgent3D
@export var weapon_rotation_speed:float = 2.0
@export var body_rotation_speed:float = 1.0
@export var move_speed:float = 3.0
@export var acceleration:float = .25
@export var attack_range:float
@export var head_node:Node3D
@export var head_lookatmodifier_node:LookAtModifier3D
@export var gun_node:Gun
@export var vert_moa:float = 600
@export var hor_moa:float = 600
@export var los_location_ratio:float = 0.6
@export var detection_radius:Area3D
@export var ballistic_detection_radius:Area3D
@export var movement_audio_player:AudioStreamPlayer3D
@export var nav_mesh_list_item:NavigationMeshListItem
@export var behavior_tree:BTPlayer
@export var physical_bone_simulator:PhysicalBoneSimulator3D
@export var animation_players:Array[AnimationPlayer]
@export var character_body_collision_shapes:Array[CollisionShape3D]
@export var loot_fiesta:LootFiestaComponent

var _target_player:Player
var target_player:Player:
	set(value):
		_target_player = value
		player_exclusions = Helpers.get_all_collision_object_3d_recursive(value)
	get:
		return _target_player

@onready var self_exclusions:Array[RID] = Helpers.get_all_collision_object_3d_recursive(self)
var _player_exclusions:Array[RID]
var player_exclusions:Array[RID]:
	set(value):
		_player_exclusions = value
		exclusions = self_exclusions + value
	get:
		return _player_exclusions
var exclusions:Array[RID]

func _ready():
	#Setting bus of instantiated in code stream player
	if movement_audio_player:
		movement_audio_player.set_bus("SFX")
	
	if detection_radius:
		detection_radius.body_entered.connect(_on_body_entered_detection_radius)
		detection_radius.body_exited.connect(_on_body_exited_detection_radius)
	if ballistic_detection_radius:
		ballistic_detection_radius.body_entered.connect(_on_body_entered_ballistic_detection_radius)
		ballistic_detection_radius.body_exited.connect(_on_body_exited_ballistic_detection_radius)
		
	if nav_agent: 
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		
		#check for existing nav map, otherwise wait for a new one
		if nav_mesh_list_item and LevelManager.level_navigation_maps.has(nav_mesh_list_item.name):
			nav_agent.set_navigation_map(LevelManager.level_navigation_maps[nav_mesh_list_item.name].map_rid)
		else:
			EventBus.navigation_mesh_list_item_baked.connect(_on_navigation_mesh_list_item_baked)
	EventBus.game_saving.connect(_on_game_saving)
	EventBus.before_game_loading.connect(_on_game_before_loading)

func move_tick(p_delta):
	if nav_agent.is_navigation_finished():
		return
	slow_body_turn(p_delta)
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var target_velocity: Vector3 = global_position.direction_to(next_path_position) * move_speed
	var new_velocity = velocity.move_toward(target_velocity, acceleration)
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
func _on_body_entered_detection_radius(body:Node3D):
	if body is Player:
		target_player = body
	
func _on_body_exited_detection_radius(body:Node3D):
	pass
	#if body is Player:
		#target_player = null
	
func _on_body_entered_ballistic_detection_radius(body:Node3D):
	if body.is_in_group("attack"):
		if body.firer and body.firer is Player:
			target_player = body.firer
	pass
	
func _on_body_exited_ballistic_detection_radius(body:Node3D):
	pass
	
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	if movement_audio_player:
		var velocity_near_zero:bool = is_zero_approx(velocity.length_squared())
		var movement_audio_playing:bool = movement_audio_player.playing
		if !velocity_near_zero and !movement_audio_playing:
			movement_audio_player.play()
		elif velocity_near_zero and movement_audio_playing:
			if movement_audio_player is IntroOutroAudioStreamPlayer:
				movement_audio_player.request_stop()
			else:
				movement_audio_player.stop()
	move_and_slide()

func slow_body_turn(delta:float):
	if velocity.length() > 0.01:
		var target_direction = velocity.normalized()
		var forward = Vector3(target_direction.x, 0, target_direction.z).normalized()  # Ignore Y component

		if forward.length() > 0:
			var current_basis = global_transform.basis.orthonormalized()
			var target_basis = Basis().looking_at(forward, Vector3.UP, true).orthonormalized()

			# Smooth interpolation
			global_transform.basis = current_basis.slerp(target_basis, delta * body_rotation_speed)  # Adjust speed


func has_attack_target() -> bool:
	if attack_target:
		return true
	else:
		return false

func set_attack_target():
	if target_player:
		attack_target = target_player.center_mass

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
		
		var los_result = Helpers.los_to_point(head_node,target_player.los_check_locations,.6,exclusions,true)
		return los_result
	else:
		return false
	
func is_near_move_target() -> bool:
	if has_move_target():
		if move_target is Area3D:
			return move_target.overlaps_body(self)
		else:
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

func stop_movement():
	nav_agent.set_velocity(Vector3.ZERO)

func set_new_path():
	if move_target and nav_agent:
		var move_target_global_position := move_target.global_position
		nav_agent.set_target_position(move_target_global_position)
		
func set_lookatmodifier_target(target_node:Node3D) -> void:
	if head_lookatmodifier_node:
		if target_node:
			head_lookatmodifier_node.target_node = target_node.get_path()
		else:
			if attack_target:
				head_lookatmodifier_node.target_node = attack_target.get_path()
			elif target_player:
				head_lookatmodifier_node.target_node = target_player.get_path()
	
func clear_lookatmodifier_target() -> void:
	head_lookatmodifier_node.target_node = NodePath()

func slow_weapon_turn():
	if attack_target:
		var delta = get_physics_process_delta_time()
		
		#if head_lookatmodifier_node and head_lookatmodifier_node.target_node.is_empty():
			#head_lookatmodifier_node.target_node = attack_target.get_path()
		if not head_lookatmodifier_node:
			Helpers.slow_rotate_to_point(head_node, attack_target.global_transform.origin, weapon_rotation_speed, delta)
		if gun_node:
			Helpers.slow_rotate_to_point(gun_node, attack_target.global_transform.origin, weapon_rotation_speed, delta)

func attack_target_in_range() -> bool:
	if attack_target:
		var distance_to_target = self.global_position.distance_to(attack_target.global_position)
		if distance_to_target <= attack_range:
			return true
	return false

func attack():
	pass
	if gun_node:
		Helpers.random_angle_deviation_moa(gun_node,vert_moa,hor_moa)
		gun_node.fireGun()
	#elif animation_player and animation_player.has_animation("attack"):
		#animation_player.play("attack")
		


func _on_navigation_mesh_list_item_baked(nmli:NavigationMeshListItem):
	if nav_mesh_list_item and nav_mesh_list_item.name == nmli.name:
		if nmli.mesh == null:
			printerr("nav mesh is null!")
		var mesh_polygon_count = nmli.mesh.get_polygon_count()
		if nmli.mesh.get_polygon_count() == 0:
			printerr("name mesh has no")
		nav_agent.set_navigation_map(nmli.map_rid)

func _on_game_saving(save_file:SaveFile):
	if save_file:
		var enemy_information:TopLevelEntitySaveData = TopLevelEntitySaveData.new()
		enemy_information.global_transform = self.global_transform
		#player_information.path_to_parent = self.get_parent().get_path()
		enemy_information.scene_path = self.scene_file_path
		save_file.top_level_entity_save_data.append(enemy_information)

func _on_game_before_loading():
	self.queue_free()
	
func _on_load_game(save_data:TopLevelEntitySaveData):
	if save_data:
		self.global_transform = save_data.global_transform

func _on_health_component_location_destroyed(health_component: HealthComponent) -> void:
	if health_component.location == HealthComponent.HEALTH_LOCATION.MAIN:
		die()
	
	pass # Replace with function body.

func die():
	print("I am dead")
	#alive = false
	if behavior_tree:
		behavior_tree.active = false
	if loot_fiesta:
		loot_fiesta.fiesta()

	if physical_bone_simulator:
		for ap3d in animation_players:
			ap3d.stop()
		for cs3d in character_body_collision_shapes:
			cs3d.disabled = true
		physical_bone_simulator.active = true
		physical_bone_simulator.physical_bones_start_simulation()
	#var damage_vector = last_damage_normal.normalized() * 5
	#PhysicsServer3D.body_set_state(physical_bone.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, damage_vector)
	#$CollisionShape3D.disabled = true
	#$CollisionShape3D2.disabled = true
	#$CollisionShape3D3.disabled = true
	#$"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head/SpotLight3D".visible = false
