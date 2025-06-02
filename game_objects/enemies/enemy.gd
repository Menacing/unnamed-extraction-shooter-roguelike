extends StaticBody3D
class_name Enemy

@export var animation_player:AnimationPlayer
@export var head_node:Node3D

@export_category("AI")
@export var sensory_component:SenseComponent
@export var state_chart:StateChart
@export var bt_player:BTPlayer
@export var bt_dictionary:Dictionary[String, BehaviorTree] = {
	"advance": preload("res://ai/trees/advance.tres"),
	"melee_attack": preload("res://ai/trees/melee_attack.tres"),
	"chase": preload("res://ai/trees/chase.tres"),
	"fire_and_advance": preload("res://ai/trees/fire_and_advance.tres"),
	"loiter": preload("res://ai/trees/loiter.tres"),
	"patrol": preload("res://ai/trees/patrol.tres"),
	"search": preload("res://ai/trees/search.tres"),
	"spotted_enemy": preload("res://ai/trees/spotted_enemy.tres")
}

@export_category("Navigation")
var _move_target:Node3D
var _move_target_gpos:Vector3
@export var nav_agent:NavigationAgent3D
@export var move_target_distance:float = 1.0
@export var nav_mesh_list_item:NavigationMeshListItem
@export var max_idle_speed:float = 3.0
@export var max_combat_speed:float = 6.0
var _current_max_speed:float
@export var acceleration:float = .25
@export var body_rotation_speed:float = 1.0
var velocity:Vector3

@export_category("Combat")
var _attack_target:Node3D
@export var weapon_rotation_speed:float = 2.0
@export var idle_reaction_time:float = 1.0
@export var combat_reaction_time:float = 0.5
var _reaction_timer:float = 0.0
@export var gun_scene:PackedScene
@export var gun_node:Gun
@export var magazine_size:int = 30
@export var vert_moa:float = 600
@export var hor_moa:float = 600
@export var firing_cooldown:float = 1.0
@export var melee_range:float = 1.0
@export var suppression_threshold = 10

@export_category("Death")
@export var loot_fiesta:LootFiestaComponent
@export var physical_bone_simulator:PhysicalBoneSimulator3D
@export var character_body_collision_shapes:Array[CollisionShape3D]

func _get_configuration_warnings():
	var warnings = []

	if nav_agent == null:
		warnings.append("nav_agent is required")

	if state_chart == null:
		warnings.append("state_chart is required")

	if bt_player == null:
		warnings.append("bt_player is required")
		
	# Returning an empty array means "no warning".
	return warnings

func _ready() -> void:
	bt_player.blackboard.set_var("animation_player", animation_player)
	bt_player.blackboard.set_var("firing_cooldown", firing_cooldown)
	
	if nav_agent: 
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		
		#check for existing nav map, otherwise wait for a new one
		if nav_mesh_list_item and LevelManager.level_navigation_maps.has(nav_mesh_list_item.name):
			nav_agent.set_navigation_map(LevelManager.level_navigation_maps[nav_mesh_list_item.name].map_rid)
		else:
			EventBus.navigation_mesh_list_item_baked.connect(_on_navigation_mesh_list_item_baked)
	EventBus.game_saving.connect(_on_game_saving)
	EventBus.before_game_loading.connect(_on_game_before_loading)
	
	if gun_scene: 
		var gun = gun_scene.instantiate()
		gun.start_highlighted = false
		gun.picked_up()
		#TODO: Pull these from the packed scene instead of being hardcoded
		gun._gun_stats.magazine_size = magazine_size
		gun.current_magazine_size = magazine_size
		var hf_pos = -gun.get_hip_fire_anchor()

		gun.position = hf_pos
		head_node.add_child(gun)
		gun.firer = self
		gun_node = gun
	elif gun_node:
		gun_node.start_highlighted = false
		gun_node.picked_up()
		gun_node._gun_stats.magazine_size = magazine_size
		gun_node.current_magazine_size = magazine_size
		gun_node.firer = self

func _start_behavior_tree(tree_name:String):
	bt_player.behavior_tree = bt_dictionary[tree_name]
	bt_player.restart()

#region movement

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	if safe_velocity != Vector3.ZERO:
		self.global_position += safe_velocity * get_physics_process_delta_time()
	#move_and_slide()

func _on_navigation_mesh_list_item_baked(nmli:NavigationMeshListItem):
	if nav_mesh_list_item and nav_mesh_list_item.name == nmli.name:
		if nmli.mesh == null:
			printerr("nav mesh is null!")
		var mesh_polygon_count = nmli.mesh.get_polygon_count()
		if nmli.mesh.get_polygon_count() == 0:
			printerr("name mesh has no")
		nav_agent.set_navigation_map(nmli.map_rid)
#endregion

#region combat
func find_best_visible_enemy():
	var new_attack_target:Node3D
	var distance_to_attack_target_sq:float
	
	for target_info:TargetInformation in sensory_component.targets.values():
		if target_info.currently_has_los:
			if new_attack_target == null:
				new_attack_target = target_info.target
				distance_to_attack_target_sq = (new_attack_target.global_position - self.global_position).length_squared()
			else:
				var distance_to_new_target_sq = (target_info.target.global_position - self.global_position).length_squared()
				if distance_to_new_target_sq < distance_to_attack_target_sq:
					new_attack_target = target_info.target
					distance_to_attack_target_sq = distance_to_new_target_sq
	
	_attack_target = new_attack_target

func find_closest_last_seen_location() -> Vector3:
	var closest_location:Vector3
	var distance_to_closest_location_sq:float
	
	for target_info:TargetInformation in sensory_component.targets.values():
		if closest_location == Vector3.ZERO:
			closest_location = target_info.last_known_position
			distance_to_closest_location_sq = (closest_location - self.global_position).length_squared()
		else:
			var distance_to_new_target_sq = (target_info.target.global_position - self.global_position).length_squared()
			if distance_to_new_target_sq < distance_to_closest_location_sq:
				closest_location = target_info.last_known_position
				distance_to_closest_location_sq = distance_to_new_target_sq
	
	return closest_location 

#endregion

#region saving

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

#endregion

#region idle states
func _on_idle_state_entered() -> void:
	_current_max_speed = max_idle_speed
	pass # Replace with function body.
	
func _on_loitering_state_entered() -> void:
	_start_behavior_tree("loiter")
	
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:

	if sensory_component.sees_enemy:
		_reaction_timer += delta
		if _reaction_timer > idle_reaction_time:
			state_chart.send_event("SpottedEnemy")
			_reaction_timer = 0.0
			return
	else:
		_reaction_timer = 0.0
	
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")


func _on_patroling_state_entered() -> void:
	_start_behavior_tree("patrol")
	
	pass # Replace with function body.
#endregion

#region combat states
func _on_combat_state_entered() -> void:
	_current_max_speed = max_combat_speed
	pass # Replace with function body.
	
func _on_spotted_enemy_state_entered() -> void:
	_start_behavior_tree("spotted_enemy")
	
	pass # Replace with function body.

func _on_spotted_enemy_state_physics_processing(delta: float) -> void:
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")

func _on_fire_and_advance_state_entered() -> void:
	_start_behavior_tree("fire_and_advance")

func _on_attacking_state_physics_processing(delta: float) -> void:
	if _attack_target == null:
		state_chart.send_event("LostTarget")
	
	pass # Replace with function body.

func _on_chasing_state_entered() -> void:
	_start_behavior_tree("chase")
	pass # Replace with function body.

func _on_chasing_state_physics_processing(delta: float) -> void:
	
	if sensory_component.sees_enemy:
		_reaction_timer += delta
		if _reaction_timer > combat_reaction_time:
			state_chart.send_event("SpottedEnemy")
			_reaction_timer = 0.0
			return
	else:
		_reaction_timer = 0.0
	
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		#find a new target
		if !sensory_component.targets.keys().is_empty():
			state_chart.send_event("Searching")
		else:
			state_chart.send_event("BT_Finished")
#endregion


func _on_health_component_location_destroyed(health_component: HealthComponent) -> void:
	if health_component.location == HealthComponent.HEALTH_LOCATION.MAIN:
		state_chart.send_event("Died")
	
	pass # Replace with function body.


func _on_dead_state_entered() -> void:
	print("I am dead")
	#alive = false
	#velocity = Vector3.ZERO
	nav_agent.velocity_computed.disconnect(_on_velocity_computed)
	if bt_player:
		bt_player.active = false
	if loot_fiesta:
		loot_fiesta.fiesta()

	if physical_bone_simulator:
		animation_player.stop()
		#for ap3d in animation_players:
			#ap3d.stop()
		for cs3d in character_body_collision_shapes:
			cs3d.disabled = true
		physical_bone_simulator.active = true
		physical_bone_simulator.physical_bones_start_simulation()

#region alert states
func _on_select_search_target_state_entered() -> void:
	if sensory_component.targets.keys().is_empty():
		state_chart.send_event("BT_Finished")
	else:
		_move_target_gpos = find_closest_last_seen_location()
			
	pass # Replace with function body.
	
func _on_searching_state_entered() -> void:
	if sensory_component.targets.keys().is_empty():
		state_chart.send_event("BT_Finished")
	_start_behavior_tree("search")
	pass # Replace with function body.

func _on_searching_state_physics_processing(delta: float) -> void:
	if sensory_component.sees_enemy:
		_reaction_timer += delta
		if _reaction_timer > combat_reaction_time:
			state_chart.send_event("SpottedEnemy")
			_reaction_timer = 0.0
			return
	else:
		_reaction_timer = 0.0
	
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		#find a new target
		if !sensory_component.targets.keys().is_empty():
			state_chart.send_event("Searching")
		else:
			state_chart.send_event("BT_Finished")
	
	pass # Replace with function body.
#endregion


func _on_advancing_state_entered() -> void:
	_start_behavior_tree("advance")
	pass # Replace with function body.

func _on_advancing_state_physics_processing(delta: float) -> void:
	var dis_to_target = _attack_target.global_position.distance_to(self.global_position)
	if _attack_target == null:
		state_chart.send_event("LostTarget")
	elif dis_to_target <= melee_range:
		state_chart.send_event("InMeleeRange")
		
	pass # Replace with function body.


func _on_melee_attacking_state_entered() -> void:
	_start_behavior_tree("melee_attack")
	pass # Replace with function body.


func _on_melee_attacking_state_physics_processing(delta: float) -> void:
	if _attack_target == null:
		state_chart.send_event("LostTarget")
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")
	pass # Replace with function body.


func _on_reloading_state_entered() -> void:
	if gun_node and gun_node is Gun:
		gun_node.current_magazine_size = magazine_size
	_start_behavior_tree("reload")
	pass # Replace with function body.


func _on_reloading_state_physics_processing(delta: float) -> void:
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")
		
	


func _on_monster_state_state_physics_processing(delta: float) -> void:
	if gun_node and gun_node is Gun and gun_node.current_magazine_size == 0:
		state_chart.send_event("Reload")
		
	if sensory_component.shots_taken.size() >= suppression_threshold:
		state_chart.send_event("Suppressed") 
