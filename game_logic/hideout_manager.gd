extends Node

var crafting_materials_resource_group:ResourceGroup = load("res://game_objects/crafting_materials/crafting_materials_resource_group.tres")
var in_hideout:bool = false
var _crafting_material_definitions:Array[CraftingMaterialDefinition]
var crafting_materials:Array[CraftingMaterialEntry] = []

#run information
var next_map:LevelInformation
var selected_run_length:GameplayEnums.GameLength
var current_map_number:int = 0
var selected_difficulty:GameplayEnums.GameDifficulty

func _ready():
	crafting_materials_resource_group.load_all_into(_crafting_material_definitions)
	for mat_def:CraftingMaterialDefinition in _crafting_material_definitions:
		var mat_entry := CraftingMaterialEntry.new()
		mat_entry.material_definition = mat_def
		mat_entry.amount = 0
		crafting_materials.append(mat_entry)

	crafting_materials.sort_custom(CraftingMaterialEntry._sort)
	
	EventBus.game_saving.connect(_on_game_saving)
	
func _on_game_saving(save_file:SaveFile):
	var run_save_data:RunSaveData = RunSaveData.new()
	#hideout_menu.save_run_data(run_save_data)
	run_save_data.selected_next_level = next_map
	run_save_data.game_length = selected_run_length
	run_save_data.current_map_number = current_map_number
	run_save_data.difficulty = selected_difficulty
	run_save_data.crafting_materials = crafting_materials
	save_file.run_save_data = run_save_data
	pass

func _on_load_game(save_data:LevelEntitySaveData):
	var run_save_data:RunSaveData = save_data.run_save_data
	next_map = run_save_data.selected_next_level
	selected_run_length = run_save_data.game_length
	current_map_number = run_save_data.current_map_number
	selected_difficulty = run_save_data.difficulty
	crafting_materials = run_save_data.crafting_materials
	#hideout_menu.load_run_data(run_save_data)
	pass


func add_crafting_material_item_instance(material:ItemInstance) -> int:
	if material._item_info is MaterialInformation:
		var mat_info:MaterialInformation = material._item_info
		for cme:CraftingMaterialEntry in crafting_materials:
			if cme.material_definition.name == mat_info.crafting_material_definition.name:
				cme.amount += material.stacks * mat_info.amount_per_stack
			
	else:
		printerr("NO MAPPING FOR ITEM %s" % material.get_item_type_id())
	
	return 0
	
func has_extracted_enough() -> bool:
	match selected_run_length:
		GameplayEnums.GameLength.SHORT:
			return current_map_number >= 3
		GameplayEnums.GameLength.MEDIUM:
			return current_map_number >= 5
		GameplayEnums.GameLength.LONG:
			return current_map_number >= 7
		_:
			return false
