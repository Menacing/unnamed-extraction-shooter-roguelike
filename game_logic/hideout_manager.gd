extends Node

@export var _hideout_menu_scene:PackedScene = load("res://ui/hideout/hideout_menu.tscn")

@onready var hideout_menu:HideoutMenu = _hideout_menu_scene.instantiate()

var crafting_materials_resource_group:ResourceGroup = load("res://game_objects/crafting_materials/crafting_materials_resource_group.tres")
var in_hideout:bool = false
var _crafting_material_definitions:Array[CraftingMaterialDefinition]
var crafting_materials:Array[CraftingMaterialEntry] = []

func _ready():
	crafting_materials_resource_group.load_all_into(_crafting_material_definitions)
	for mat_def:CraftingMaterialDefinition in _crafting_material_definitions:
		var mat_entry := CraftingMaterialEntry.new()
		mat_entry.material_definition = mat_def
		mat_entry.amount = 0
		crafting_materials.append(mat_entry)
	crafting_materials.sort_custom(CraftingMaterialEntry._sort)
	EventBus.game_saving.connect(_on_game_saving)
	self.add_child(hideout_menu)
	
func _on_game_saving(save_file:SaveFile):
	#TODO Figure out how to save state of the Hideout
	pass

func _on_load_game(save_data:LevelEntitySaveData):
	pass


func show_hideout_menu():
	hideout_menu.visible = true
	EventBus.add_control_to_HUD.emit(hideout_menu)
	
func hide_hideout_menu():
	EventBus.remove_control_from_HUD.emit(hideout_menu)
