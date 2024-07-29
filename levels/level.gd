extends WorldEnvironment
class_name Level

var player_scene:PackedScene = preload("res://game_objects/player/player.tscn")

@export var is_hideout:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.populate_level.connect(_on_populate_level)
	EventBus.game_saving.connect(_on_game_saving)
	if is_hideout:
		HideoutManager.in_hideout = true
	else:
		HideoutManager.in_hideout = false

func _on_game_saving(save_file:SaveFile):
	if save_file:
		save_file.level_scene_path = self.scene_file_path

func _on_populate_level():
	setup_player_spawn()

func setup_player_spawn():
	if is_hideout:
		#get player spawn
		var player_spawns = get_tree().get_nodes_in_group("PlayerSpawn")
		var player_spawn = player_spawns.pop_front()
		
		#spawn player there
		EventBus.player_spawning.emit()
		var player:Player = player_scene.instantiate()
		player.global_position = player_spawn.global_position
		add_child(player)
		
		EventBus.players_spawned.emit()
	else:
		#get all extracts
		var extracts:Array[Node] = get_tree().get_nodes_in_group("Extract")
		extracts.shuffle()
		#pick one
		var selected_extract:AreaExtract = extracts.pop_back()
		#disable others
		for extract:AreaExtract in extracts:
			extract.disable()
		#get linked extract
		var node_name:String = "%"+selected_extract.targetname
		var linked_extract:AreaExtract = get_node(node_name)
		#spawn player there
		EventBus.player_spawning.emit()
		var player:Player = player_scene.instantiate()
		player.global_position = linked_extract.global_position
		add_child(player)
		
		EventBus.players_spawned.emit()
