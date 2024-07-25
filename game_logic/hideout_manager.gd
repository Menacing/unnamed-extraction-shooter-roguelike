extends Node

@export var _hideout_menu_scene:PackedScene = load("res://ui/hideout_menu.tscn")

@onready var hideout_menu:HideoutMenu = _hideout_menu_scene.instantiate()

var crafting_materials_resource_group:ResourceGroup = load("res://game_objects/crafting_materials/crafting_materials_resource_group.tres")
var in_hideout:bool = false
var _crafting_material_definitions:Array[CraftingMaterialDefinition]
var crafting_materials:Array[CraftingMaterialEntry] = []

func _ready():
	crafting_materials_resource_group.load_all_into(_crafting_material_definitions)

func show_hideout_menu():
	EventBus.add_control_to_HUD.emit(hideout_menu)
	
func hide_hideout_menu():
	EventBus.remove_control_from_HUD.emit(hideout_menu)
