extends TabContainer
class_name HideoutMenu

@export var tab_bar:TabContainer

@export var stash_tab_index:int
@export var stash_inventory_control:InventoryControl

@export var map_select_tab_index:int
@export var map_select_control:MapSelectionMenu

@export var printer_tab_index:int

@export var workbench_tab_index:int


func show_stash_tab():
	tab_bar.current_tab = stash_tab_index

func show_map_select_tab():
	tab_bar.current_tab = map_select_tab_index
	
func show_printer_tab():
	tab_bar.current_tab = printer_tab_index
	
func show_workbench_tab():
	tab_bar.current_tab = workbench_tab_index

func save_run_data(run_data:RunSaveData):
	if map_select_control:
		map_select_control.save_run_data(run_data)
	return

func load_run_data(run_save_data:RunSaveData):
	if map_select_control:
		map_select_control.load_run_data(run_save_data)
