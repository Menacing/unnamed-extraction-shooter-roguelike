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

var current_stash_size:StashContainer.StashSize = StashContainer.StashSize.SMALL
var inventory_data:InventoryData
var remaining_lives:int = 0:
	get:
		return remaining_lives
	set(value):
		remaining_lives = value
		lives_changed.emit()

var current_printer_size:PrinterStation.PrinterSize = PrinterStation.PrinterSize.UNBUILT:
	get:
		return current_printer_size
	set(value):
		current_printer_size = value
		printer_size_changed.emit()
		
signal printer_size_changed
signal print_item(item_to_print:ItemInformation)
signal lives_changed

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
	run_save_data.stash_size = current_stash_size
	run_save_data.printer_level = current_printer_size
	run_save_data.remaining_lives = remaining_lives
	
	save_file.run_save_data = run_save_data
	pass

func _on_load_game(save_data:LevelEntitySaveData):
	var run_save_data:RunSaveData = save_data.run_save_data
	next_map = run_save_data.selected_next_level
	selected_run_length = run_save_data.game_length
	current_map_number = run_save_data.current_map_number
	selected_difficulty = run_save_data.difficulty
	crafting_materials = run_save_data.crafting_materials
	current_stash_size = run_save_data.stash_size
	current_printer_size = run_save_data.printer_level
	remaining_lives = run_save_data.remaining_lives
	#hideout_menu.load_run_data(run_save_data)
	pass


func add_crafting_material(material:SlotData) -> int:
	if material.item_data is MaterialInformation:
		var mat_info:MaterialInformation = material.item_data
		for cme:CraftingMaterialEntry in crafting_materials:
			if cme.material_definition.name == mat_info.crafting_material_definition.name:
				cme.amount += material.quantity * mat_info.amount_per_stack
				EventBus.material_changed.emit(cme)
	else:
		printerr("NO MAPPING FOR ITEM %s" % material.get_item_type_id())
	
	return 0

func remove_crafting_material(material_name:String, amount:int):
	for cme:CraftingMaterialEntry in crafting_materials:
		if cme.material_definition.name == material_name:
			cme.amount -= amount
			EventBus.material_changed.emit(cme)

func get_crafting_material_amount(material_name:String) -> int:
	for cme:CraftingMaterialEntry in crafting_materials:
		if cme.material_definition.name == material_name:
			return cme.amount
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

func _on_stash_upgraded():
	match current_stash_size:
		StashContainer.StashSize.SMALL:
			current_stash_size = StashContainer.StashSize.MEDIUM
		StashContainer.StashSize.MEDIUM:
			current_stash_size = StashContainer.StashSize.LARGE
		StashContainer.StashSize.LARGE:
			printerr("Can't upgrade Stash any farther!")
		_:
			printerr("Setting stash to invalide size")
	
	inventory_data.set_inventory_size(current_stash_size)
	pass

func _on_printer_upgraded():
	match current_printer_size:
		PrinterStation.PrinterSize.UNBUILT:
			current_printer_size = PrinterStation.PrinterSize.SMALL
		PrinterStation.PrinterSize.SMALL:
			current_printer_size = PrinterStation.PrinterSize.MEDIUM
		_:
			printerr("Setting printer to invalide size")
