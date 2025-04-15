extends Node

var level_infos:Array[LevelInformation] = []
var current_shuffle_bag:Array[LevelInformation] = []
var resource_group:ResourceGroup = load("res://levels/maps/map_information_resource_group.tres")
const HIDEOUT_SCENE = preload("res://levels/hideout.tscn")

#The instantiated hideout scene
var hideout_level:Level
#The instantiated previous level
var previous_level:Level
#The instantiated next level.
var next_level:Level
#The level that is actually loaded as a child of the level manager
var loaded_level:Node


var level_navigation_maps:Dictionary = {}

#Used by sense component so we only get nodes out of the tree once per frame and not once per enemy
var viewable_entities:Array[Node] = []

func _ready():
	hideout_level = HIDEOUT_SCENE.instantiate()
	# fills the array with the resources from the resource group
	resource_group.load_all_into(level_infos)
	if level_infos.size() == 0:
		push_error("NO LEVEL INFORMATION FOUND")
		
func _physics_process(delta: float) -> void:
	viewable_entities = get_tree().get_nodes_in_group("viewable_entity")

func clear_level():
	for child in get_children():
		remove_child(child)
		child.queue_free()

func load_hideout_async(extracted:bool = false, died:bool = false):
	# wait a physics frame so we can modify the tree
	await get_tree().physics_frame
	get_tree().paused = true
	
	# load the next level
	EventBus.before_level_loading.emit()

	EventBus.before_previous_level_freed.emit()
	#pull players out of tree
	for player in get_tree().get_nodes_in_group("players"):
		Helpers.force_parent(player, self)
		
	# kill everything below the world root
	for child in get_children():
		if not child.is_in_group("world_root_no_touch") and not child.is_in_group("players"):
			if child is Level:
				child.disconnect_level()
				previous_level = child
				self.remove_child(child)
			else:
				#remove_child(child)
				child.queue_free()
		
	#Add players to new level
	for player in get_tree().get_nodes_in_group("players"):
		Helpers.force_parent(player, hideout_level)
	# add to world root
	add_child(hideout_level)
	hideout_level.connect_level()
	
	hideout_level.setup_player_spawn()
	
	call_deferred("emit_populate_level")
	await EventBus.level_populated
	
	loaded_level = hideout_level
	get_tree().paused = false
	# connect the signal to get notified when the exit is reached
	EventBus.level_loaded.emit()
	
	if extracted:
		get_tree().call_group("has_on_extracted_function", "_on_extracted")
	if died:
		get_tree().call_group("has_on_died_function", "_on_died")
	pass

func load_level_async(path:String, populate_level:bool = false):
	if path:
		# wait a physics frame so we can modify the tree
		await get_tree().physics_frame
		get_tree().paused = true
		
		# load the next level
		EventBus.before_level_loading.emit()
		# instantiate the new level
		var next_level:Level = load(path).instantiate()
		#next_level.exit_reached.connect(_on_level_exit_reached)
		
		EventBus.before_previous_level_freed.emit()
		#pull players out of tree
		for player in get_tree().get_nodes_in_group("players"):
			Helpers.force_parent(player, self)
			
		# kill everything below the world root
		for child in get_children():
			if not child.is_in_group("world_root_no_touch") and not child.is_in_group("players"):
				if child is Level:
					child.disconnect_level()
					self.remove_child(child)
					if !child.is_hideout:
						if previous_level:
							previous_level.queue_free()
						previous_level = child
				else:
					#remove_child(child)
					child.queue_free()
			
		#Add players to new level
		for player in get_tree().get_nodes_in_group("players"):
			Helpers.force_parent(player, next_level)
		# add to world root
		add_child(next_level)
		next_level.connect_level()
		
		next_level.setup_player_spawn()
		
		if populate_level:
			call_deferred("emit_populate_level")
			await EventBus.level_populated
		
		loaded_level = next_level
		get_tree().paused = false
		# connect the signal to get notified when the exit is reached
		EventBus.level_loaded.emit()
	else:
		print("Can't load level with no path")

func load_previous_level_async():
	if previous_level:
		# wait a physics frame so we can modify the tree
		await get_tree().physics_frame
		get_tree().paused = true
		
		# load the next level
		EventBus.before_level_loading.emit()
		# instantiate the new level
		var next_level:Level = previous_level
		#next_level.exit_reached.connect(_on_level_exit_reached)
		
		EventBus.before_previous_level_freed.emit()
		#pull players out of tree
		for player in get_tree().get_nodes_in_group("players"):
			Helpers.force_parent(player, self)
			
		# kill everything below the world root
		for child in get_children():
			if not child.is_in_group("world_root_no_touch") and not child.is_in_group("players"):
				if child is Level:
					child.disconnect_level()
					self.remove_child(child)
					if !child.is_hideout:
						if previous_level:
							previous_level.queue_free()
						previous_level = child
				else:
					#remove_child(child)
					child.queue_free()
			
		#Add players to new level
		for player in get_tree().get_nodes_in_group("players"):
			Helpers.force_parent(player, next_level)
		# add to world root
		add_child(next_level)
		next_level.connect_level()
		
		next_level.setup_player_spawn()
		
		if !next_level.populated:
			call_deferred("emit_populate_level")
			await EventBus.level_populated
		
		loaded_level = next_level
		get_tree().paused = false
		# connect the signal to get notified when the exit is reached
		EventBus.level_loaded.emit()
	else:
		printerr("NO PREVIOUS LEVEL TO LOAD")



func emit_populate_level():
	EventBus.before_populate_level.emit()
	EventBus.populate_level.emit()
	EventBus.level_populated.emit()

func add_node_to_level(node:Node) -> bool:
	if loaded_level and node:
		loaded_level.add_child(node)
		return true
	else:
		return false

func get_level_informations(number:int) -> Array[LevelInformation]:
	var return_array:Array[LevelInformation] = []
	if number <= 0:
		return return_array
	for i in number:
		if current_shuffle_bag.size() == 0:
			current_shuffle_bag = level_infos.duplicate(true)
			current_shuffle_bag.shuffle()
		return_array.append(current_shuffle_bag.pop_back())
	
	return return_array
