extends CharacterBody3D
class_name Enemy

@export var animation_player:AnimationPlayer
@export var head_node:Node3D

@export_category("AI")
@export var sensory_component:SenseComponent
@export var state_chart:StateChart
@export var bt_player:BTPlayer

@export_category("Navigation")
var _move_target:Node3D
@export var nav_agent:NavigationAgent3D
@export var move_target_distance:float = 1.0
@export var nav_mesh_list_item:NavigationMeshListItem
@export var max_idle_speed:float = 3.0
@export var max_combat_speed:float = 6.0
var _current_max_speed:float
@export var acceleration:float = .25
@export var body_rotation_speed:float = 1.0

@export_category("Combat")
var _attack_target:Node3D
@export var weapon_rotation_speed:float = 2.0
@export var idle_reaction_time:float = 1.0
@export var combat_reaction_time:float = 0.5
var _reaction_timer:float = 0.0
@export var gun_scene:PackedScene
@export var gun_node:Gun
@export var vert_moa:float = 600
@export var hor_moa:float = 600

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
		gun._gun_stats.magazine_size = 30000
		gun.current_magazine_size = 30000
		var hf_pos = -gun.get_hip_fire_anchor()

		gun.position = hf_pos
		head_node.add_child(gun)
		gun.firer = self
		gun_node = gun

#region movement

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

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
	
	if new_attack_target == null:
		state_chart.send_event("LostTarget")

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
	var loitering_bt = load("res://ai/trees/loiter.tres")
	bt_player.behavior_tree = loitering_bt
	
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
	var loitering_bt = load("res://ai/trees/patrol.tres")
	bt_player.behavior_tree = loitering_bt
	
	pass # Replace with function body.
#endregion

#region combat states
func _on_combat_state_entered() -> void:
	_current_max_speed = max_combat_speed
	pass # Replace with function body.
	
func _on_spotted_enemy_state_entered() -> void:
	var spotted_enemy_bt = load("res://ai/trees/spotted_enemy.tres")
	bt_player.behavior_tree = spotted_enemy_bt
	
	pass # Replace with function body.

func _on_spotted_enemy_state_physics_processing(delta: float) -> void:
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")

func _on_attacking_state_entered() -> void:
	var attack_bt = load("res://ai/trees/attack.tres")
	bt_player.behavior_tree = attack_bt

func _on_attacking_state_physics_processing(delta: float) -> void:
	
	
	pass # Replace with function body.
	
func _on_chasing_state_entered() -> void:
	var chase_bt = load("res://ai/trees/chase.tres")
	bt_player.behavior_tree = chase_bt
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
		state_chart.send_event("BT_Finished")
#endregion
