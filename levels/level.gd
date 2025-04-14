extends WorldEnvironment
class_name Level

var player_scene:PackedScene = preload("res://game_objects/player/player.tscn")

@export var is_hideout:bool = false

@export var nodes_to_remove_medium:Array[Node]
@export var nodes_to_remove_hard:Array[Node]

var populated:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_hideout:
		HideoutManager.in_hideout = true
	else:
		HideoutManager.in_hideout = false
		
	if HideoutManager.selected_difficulty == GameplayEnums.GameDifficulty.MEDIUM:
		for node in nodes_to_remove_medium:
			node.queue_free()
	elif HideoutManager.selected_difficulty == GameplayEnums.GameDifficulty.HARD:
		for node in nodes_to_remove_hard:
			node.queue_free()

func _on_game_saving(save_file:SaveFile):
	if save_file:
		save_file.level_scene_path = self.scene_file_path

func _on_populate_level():
	setup_player_spawn()
	
	get_tree().call_group("has_on_populate_level_function", "_on_populate_level")
	
	populated = true
	

func connect_level():
	EventBus.populate_level.connect(_on_populate_level)
	EventBus.game_saving.connect(_on_game_saving)
	if is_hideout:
		HideoutManager.in_hideout = true
	else:
		HideoutManager.in_hideout = false

func disconnect_level():
	EventBus.populate_level.disconnect(_on_populate_level)
	EventBus.game_saving.disconnect(_on_game_saving)

func setup_player_spawn():
	if is_hideout:
		#get player spawn
		var player_spawns = get_tree().get_nodes_in_group("PlayerSpawn")
		var player_spawn = player_spawns.pop_front()
		
		place_player(player_spawn.global_position)
		

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
		place_player(linked_extract.global_position)
		
		EventBus.players_spawned.emit()

func place_player(pos:Vector3):
	EventBus.player_spawning.emit()
	
	#check for existing players
	var players = get_tree().get_nodes_in_group("players")
	var player:Player
	if players.size() > 0:
		player = players.pop_front()
	else:
		player = player_scene.instantiate() 

	player.global_position = pos
	Helpers.force_parent(player, self)
	print(str(player.get_groups()))
	EventBus.players_spawned.emit()
	
