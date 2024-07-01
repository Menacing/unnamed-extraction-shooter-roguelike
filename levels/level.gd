extends WorldEnvironment

var player_scene:PackedScene = preload("res://game_objects/player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setup_player_spawn")


func setup_player_spawn():
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
	var player:Player = player_scene.instantiate()
	player.global_position = linked_extract.global_position
	add_child(player)
