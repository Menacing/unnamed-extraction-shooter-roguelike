@tool
extends Node

var _current_shuffle_bags:Dictionary = {}
var _model_shuffle_bags:Dictionary = {}

func create_empty_shuffle_bags():
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.GENERIC, GameplayEnums.Tier.UNIQUE)] = []
	
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.EASI, GameplayEnums.Tier.UNIQUE)] = []
	
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.CENT, GameplayEnums.Tier.UNIQUE)] = []
	
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.WODC, GameplayEnums.Tier.UNIQUE)] = []

	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MEDICAL, GameplayEnums.Tier.UNIQUE)] = []

	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.SCIENCE, GameplayEnums.Tier.UNIQUE)] = []
	
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.COMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.COMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.UNCOMMON)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.UNCOMMON)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.RARE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.RARE)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.EPIC)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.EPIC)] = []
	_current_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.UNIQUE)] = []
	_model_shuffle_bags[_map_loot_spawn_key_to_string(GameplayEnums.LootTable.MILITARY, GameplayEnums.Tier.UNIQUE)] = []

func _ready() -> void:
	create_empty_shuffle_bags()

	for item_info in ItemMappingRepository.get_all_item_information():
		#generate shufflebags
		for spawn_info in item_info.item_spawn_informations:
			var model_shuffle_bag:Array[String] = []
			for i in range(get_rarity_value(spawn_info.rarity)):
				model_shuffle_bag.append(item_info.item_type_id)

			# for items tier and above, add it to the model shuffle bag
			var current_tier = spawn_info.tier
			while current_tier <= GameplayEnums.Tier.UNIQUE:
				_model_shuffle_bags[_map_loot_spawn_key_to_string(spawn_info.loot_table, current_tier)].append_array(model_shuffle_bag)
				current_tier += 1
		

func _map_loot_spawn_key_to_string(loot_table:GameplayEnums.LootTable, tier:GameplayEnums.Tier) -> String:
	return str(loot_table) + "-" + str(tier)

func get_spawn_info(loot_table:GameplayEnums.LootTable, tier:GameplayEnums.Tier) -> ItemInformation:
	var current_shuffle_bag = _current_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)]
	var model_shuffle_bag = _model_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)]
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
		_current_shuffle_bags[_map_loot_spawn_key_to_string(loot_table, tier)] = current_shuffle_bag
	
	return ItemMappingRepository.get_item_information(current_shuffle_bag.pop_front())

func get_difficulty_loot_factor() -> float:
	match HideoutManager.selected_difficulty: 
		GameplayEnums.GameDifficulty.EASY:
			return 1.0
		GameplayEnums.GameDifficulty.MEDIUM:
			return 0.75
		GameplayEnums.GameDifficulty.HARD:
			return 0.5
		_:
			return 1.0

func get_rarity_value(rarity:GameplayEnums.Rarity) -> int:
	match rarity:
		GameplayEnums.Rarity.COMMON:
			return 5
		GameplayEnums.Rarity.UNCOMMON:
			return 4
		GameplayEnums.Rarity.RARE:
			return 3
		GameplayEnums.Rarity.EPIC:
			return 2
		GameplayEnums.Rarity.UNIQUE:
			return 1
		_:
			return 0

func get_run_loot_tier_bonus() -> int:
	var current_extracts:float = float(HideoutManager.current_map_number)
	var percent_complete:float = 0.0
	match HideoutManager.selected_run_length:
			GameplayEnums.GameLength.SHORT:
				percent_complete = current_extracts/3.0
			GameplayEnums.GameLength.MEDIUM:
				percent_complete = current_extracts/5.0
			GameplayEnums.GameLength.LONG:
				percent_complete = current_extracts/7.0
			_:
				return 0
	if percent_complete >= 0.65:
		return 2
	elif percent_complete >= 0.32:
		return 1
	else:
		return 0

func populate_level() -> void:
	pass
	## get all loot spawn containers and areas
	
	var spawn_areas = get_tree().get_nodes_in_group("loot_spawn_area")
	var spawn_containers = get_tree().get_nodes_in_group("loot_spawn_container")
	
	## create loot spawn shuffle bags
	var model_spawn_location_shuffle_bag = []
	var current_spawn_location_shuffle_bag = []
	
	for spawn_area in spawn_areas:
		if spawn_area and spawn_area is AreaLootSpawn:
			for i in range(get_rarity_value(spawn_area.rarity)):
				model_spawn_location_shuffle_bag.append(spawn_area)
	
	for spawn_container in spawn_containers:
		if spawn_container and spawn_container is GeoBallisticContainer:
			for i in range(get_rarity_value(spawn_container.rarity)):
				model_spawn_location_shuffle_bag.append(spawn_container)
				
	current_spawn_location_shuffle_bag = model_spawn_location_shuffle_bag.duplicate()
	current_spawn_location_shuffle_bag.shuffle()
	
	## determine number of items to spawn
	var number_items_to_spawn:int= 0
	
	if LevelManager.loaded_level_info:
		match LevelManager.loaded_level_info.size:
			LevelInformation.Size.Small:
				number_items_to_spawn = Helpers.get_normalized_random_stack_count(100, 200, 300)
			LevelInformation.Size.Medium:
				number_items_to_spawn = Helpers.get_normalized_random_stack_count(200, 400, 600)
			LevelInformation.Size.Large:
				number_items_to_spawn = Helpers.get_normalized_random_stack_count(400, 600, 800)
			_:
				number_items_to_spawn = Helpers.get_normalized_random_stack_count(100, 200, 300)
	else:
		number_items_to_spawn = Helpers.get_normalized_random_stack_count(100, 200, 300)
		
	## for each
	for i in range(number_items_to_spawn):
		## Grab non-full spawn location
		if current_spawn_location_shuffle_bag.is_empty():
			for q in model_spawn_location_shuffle_bag.size():
				var sl = model_spawn_location_shuffle_bag[q]
				if sl.number_spawned >= sl.max_spawned:
					model_spawn_location_shuffle_bag.remove_at(q)
					
			## ran out of space, done spawning
			if model_spawn_location_shuffle_bag.size() == 0:
				printerr("NO MORE ROOM IN LEVEL TO SPAWN ITEMS")
				return
			
			current_spawn_location_shuffle_bag = model_spawn_location_shuffle_bag.duplicate()
		
		var valid_spawn_location
		while current_spawn_location_shuffle_bag.size() > 0:
			var spawn_location = current_spawn_location_shuffle_bag.pop_front()
			if spawn_location.number_spawned < spawn_location.max_spawned:
				valid_spawn_location = spawn_location
				break
			
		if valid_spawn_location:
			## Grab item information
			var item_info:ItemInformation = get_spawn_info(valid_spawn_location.loot_table, valid_spawn_location.tier)
			## Try to spawn item
			if valid_spawn_location is AreaLootSpawn:
				try_to_spawn_area_loot_spawn(item_info, valid_spawn_location)
			elif valid_spawn_location is GeoBallisticContainer:
				try_to_spawn_geo_ballistic_container(item_info, valid_spawn_location)
				
			## increment items in location
			valid_spawn_location.number_spawned += 1
		
		
func try_to_spawn_area_loot_spawn(item_info:ItemInformation, area:AreaLootSpawn) -> void:
	var aabb = Helpers.get_aabb_of_node(area)
	var x_begin = aabb.position.x
	var x_end = aabb.end.x
	var z_begin = aabb.position.z
	var z_end = aabb.end.z

	#generate random location
	var try_pos = Vector3(randf_range(x_begin,x_end),0,randf_range(z_begin,z_end))

	var slot_data = SlotData.instantiate_from_item_information(item_info)
	var scene = Item3D.instantiate_from_slot_data(slot_data)
	scene.set_as_top_level(true)
	LevelManager.add_node_to_level.call_deferred(scene)
	scene.set_global_position.call_deferred(try_pos + area.global_position)
	var random_rotation = Vector3(randf_range(0,360),randf_range(0,360),randf_range(0,360))
	scene.set_rotation_degrees.call_deferred(random_rotation)

	return
		
func try_to_spawn_geo_ballistic_container(item_info:ItemInformation, gbc:GeoBallisticContainer) -> void:
	assert(gbc.inventory_data != null)
	if gbc.inventory_data:
		var slot_data:SlotData = SlotData.instantiate_from_item_information(item_info)
		gbc.inventory_data.pick_up_slot_data(slot_data)
	else:
		printerr("GEOBALLISTICCONTAINER MISSING INVENTORY DATA")
	return
