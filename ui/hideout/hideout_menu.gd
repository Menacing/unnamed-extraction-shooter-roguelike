extends TabContainer
class_name HideoutMenu

@export var tab_bar:TabContainer

@export var stash_tab_index:int
@export var stash_inventory_control:InventoryControl

@export var map_select_tab_index:int
@export var map_select_control:MapSelectionMenu

@export var polymer_label: Label 
@export var scrap_metal_label: Label 
@export var bio_gel_label: Label 

func _ready() -> void:
	for material:CraftingMaterialEntry in HideoutManager.crafting_materials:
		match material.material_definition.name:
			"Polymer":
				material.amount_changed.connect(update_material_label.bind(polymer_label))
			"Bio Gel":
				material.amount_changed.connect(update_material_label.bind(bio_gel_label))
			"Scrap Metal":
				material.amount_changed.connect(update_material_label.bind(scrap_metal_label))
	$STASH/VBoxContainer/UpgradeHBoxContainer.upgrade_triggered.connect(HideoutManager._on_stash_upgraded)

func show_stash_tab():
	tab_bar.current_tab = stash_tab_index

func show_map_select_tab():
	tab_bar.current_tab = map_select_tab_index

func save_run_data(run_data:RunSaveData):
	if map_select_control:
		map_select_control.save_run_data(run_data)
	return

func load_run_data(run_save_data:RunSaveData):
	if map_select_control:
		map_select_control.load_run_data(run_save_data)
		

func update_material_label(amount:int, label:Label) -> void:
	label.text = str(amount)
