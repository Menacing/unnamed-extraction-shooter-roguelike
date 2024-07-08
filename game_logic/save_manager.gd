extends Node

signal game_saving(save_file:SaveFile)
signal game_before_loading


func quick_save():
	save_game("quicksave")

func save_game(file_name:String):
	
	var new_save_file = SaveFile.new()
	new_save_file.game_version = ProjectSettings.get_setting("application/config/version")
	game_saving.emit(new_save_file)
	
	
	ResourceSaver.save(new_save_file, "user://"+file_name+".tres")
	
	EventBus.create_message.emit("quick_save_message", "Game Saved", 5.0)


func load_game(file_path:String):
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
	game_before_loading.emit()
	
	#restore all dynamic game elements
	for item:WorldEntitySaveData in saved_game.save_data:
		# load the scene of the saved item and create a new instance
		var scene := load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		if item.path_to_parent:
			#TODO: if the node needs to be someplace specific in the node tree, put it there I guess
			pass
		
		LevelManager.add_node_to_level(restored_node)
		if restored_node.has_method("_on_load_game"):
			restored_node._on_load_game(item)
		
	#for item in saved_game.saved_data:
		### skip over data we don't use anymore
		##if item is UnusedData:
			##continue
		#
		## load the scene of the saved item and create a new instance
		#var scene := load(item.scene_path) as PackedScene
		#var restored_node = scene.instantiate()
		## add it to the world root
		#_world_root.add_child(restored_node)
		## and run any custom load logic
		#if restored_node.has_method("on_load_game"):
			#restored_node.on_load_game(item)

func quick_load():
	load_game("user://quicksave.tres")
