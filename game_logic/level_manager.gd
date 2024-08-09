extends Node

var level_infos:Array[LevelInformation] = []
var current_shuffle_bag:Array[LevelInformation] = []
var resource_group:ResourceGroup = load("res://levels/biomes/map_information_resource_group.tres")

var current_level:Node

func _ready():
	# declare a type safe array

	# fills the array with the resources from the resource group
	resource_group.load_all_into(level_infos)
	if level_infos.size() == 0:
		push_error("NO LEVEL INFORMATION FOUND")

func clear_level():
	for child in get_children():
		remove_child(child)
		child.queue_free()

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
		if current_level != null:
			current_level.queue_free()
		for child in get_children():
			if not child.is_in_group("world_root_no_touch") and not child.is_in_group("players"):
				if child is Level:
					child.unload_level()
				else:
					#remove_child(child)
					child.queue_free()
			
		#Add players to new level
		for player in get_tree().get_nodes_in_group("players"):
			Helpers.force_parent(player, next_level)
		# add to world root
		add_child(next_level)
		
		if populate_level:
			if current_level:
				await current_level.tree_exited
			call_deferred("emit_populate_level")
			await EventBus.level_populated
		
		current_level = next_level
		get_tree().paused = false
		# connect the signal to get notified when the exit is reached
		EventBus.level_loaded.emit()
	else:
		print("Can't load level with no path")

func emit_populate_level():
	EventBus.before_populate_level.emit()
	EventBus.populate_level.emit()
	EventBus.level_populated.emit()

func add_node_to_level(node:Node):
	current_level.add_child(node)

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
