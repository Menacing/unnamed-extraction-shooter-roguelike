extends CharacterBody3D
class_name Enemy

@export var animation_player:AnimationPlayer

@export_category("AI")
@export var sensory_component:SenseComponent
@export var state_chart:StateChart
@export var bt_player:BTPlayer

@export_category("Navigation")
@export var nav_agent:NavigationAgent3D
@export var move_target_distance:float = 1.0
@export var nav_mesh_list_item:NavigationMeshListItem
@export var max_idle_speed:float = 3.0
@export var max_combat_speed:float = 6.0
@export var acceleration:float = .25
@export var body_rotation_speed:float = 1.0

func _ready() -> void:
	bt_player.blackboard.set_var("animation_player", animation_player)
	bt_player.blackboard.set_var("nav_agent", nav_agent)
	bt_player.blackboard.set_var("move_target_distance", move_target_distance)
	bt_player.blackboard.set_var("max_move_speed", max_idle_speed)
	bt_player.blackboard.set_var("acceleration", acceleration)
	bt_player.blackboard.set_var("body_rotation_speed", body_rotation_speed)

	if nav_agent: 
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		
		#check for existing nav map, otherwise wait for a new one
		if nav_mesh_list_item and LevelManager.level_navigation_maps.has(nav_mesh_list_item.name):
			nav_agent.set_navigation_map(LevelManager.level_navigation_maps[nav_mesh_list_item.name].map_rid)
		else:
			EventBus.navigation_mesh_list_item_baked.connect(_on_navigation_mesh_list_item_baked)
	EventBus.game_saving.connect(_on_game_saving)
	EventBus.before_game_loading.connect(_on_game_before_loading)

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
func _on_loitering_state_entered() -> void:
	var loitering_bt = load("res://ai/trees/loiter.tres")
	bt_player.behavior_tree = loitering_bt
	
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	var bt_status:BT.Status = bt_player.get_bt_instance().get_last_status()
	if bt_status != BT.Status.RUNNING:
		state_chart.send_event("BT_Finished")


func _on_patroling_state_entered() -> void:
	var loitering_bt = load("res://ai/trees/patrol.tres")
	bt_player.behavior_tree = loitering_bt
	
	pass # Replace with function body.
#endregion
