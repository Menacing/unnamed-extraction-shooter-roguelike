extends Node



func quick_save():
	save_game("quicksave")

func save_game(file_name:String) -> SaveFile:
	
	var new_save_file = SaveFile.new()
	new_save_file.game_version = ProjectSettings.get_setting("application/config/version")
	EventBus.game_saving.emit(new_save_file)
	
	ResourceSaver.save(new_save_file, "user://"+file_name+".tres")
	
	EventBus.create_message.emit("quick_save_message", "Game Saved", 5.0)
	EventBus.game_saved.emit()
	
	return new_save_file

func load_game(file_path:String) -> SaveFile:
	## fix any paths that may be broken after a game update
	#var fixed_path = PathFixer.fix_paths("user://savegame.tres")
	#print("Loading from ", fixed_path )
	
	# load the savegame securely
	var saved_game:SaveFile = SafeResourceLoader.load(file_path) as SaveFile
	if saved_game == null:
		return
	
	# first restore the level
	# this may take a few frames, so we wait with await
	await LevelManager.load_level_async(saved_game.level_scene_path)
	
	# clear the stage
	EventBus.before_game_loading.emit()
	
	#restore all root game elements
	for item:TopLevelEntitySaveData in saved_game.top_level_entity_save_data:
		# load the scene of the saved item and create a new instance
		var scene := load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		
		LevelManager.add_node_to_level(restored_node)
		if restored_node.has_method("_on_load_game"):
			restored_node._on_load_game(item)
	
	#restore all level elements
	for item:LevelEntitySaveData in saved_game.level_entity_save_data:
		#get the node
		var node_to_restore:Node = get_node(item.node_path)
		
		if node_to_restore.has_method("_on_load_game"):
			node_to_restore._on_load_game(item)
	
	#restore items in inventories
	await get_tree().process_frame
	#InventoryManager._restore_inventories()
	print("finished loading!")
	EventBus.game_loaded.emit()
	
	return saved_game

func quick_load():
	load_game("user://quicksave.tres")
