extends Node

var current_level:Node

func load_level_async(path:String, populate_level:bool = false):
	# wait a physics frame so we can modify the tree
	await get_tree().physics_frame
	get_tree().paused = true
	
	# load the next level
	var next_level:Level = load(path).instantiate()
	#next_level.exit_reached.connect(_on_level_exit_reached)
	
	# kill everything below the world root
	for child in get_children():
		if not child.is_in_group("world_root_no_touch"):
			remove_child(child)
			child.queue_free()
		
	# instantiate the new level
	# add to world root
	add_child(next_level)
	current_level = next_level
	
	if populate_level:
		call_deferred("emit_populate_level")
	
	get_tree().paused = false
	# connect the signal to get notified when the exit is reached

func emit_populate_level():
	EventBus.populate_level.emit()

func add_node_to_level(node:Node):
	current_level.add_child(node)