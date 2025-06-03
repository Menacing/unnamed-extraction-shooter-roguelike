@tool
extends Marker3D

var ray_player_mapping:Dictionary[RayCast3D, Player]

func _ready() -> void:
	EventBus.players_spawned.connect(create_player_rays)
	create_player_rays()

func create_player_rays():
	print("create_player_rays")
	var players = get_tree().get_nodes_in_group("players")
	for child in self.get_children():
		child.queue_free()
	
	for player in players:
		var rc = RayCast3D.new()
		self.add_child(rc)
		rc.target_position = self.to_local(player.global_position)
		rc.owner = get_tree().edited_scene_root
		rc.collision_mask = 2
		
