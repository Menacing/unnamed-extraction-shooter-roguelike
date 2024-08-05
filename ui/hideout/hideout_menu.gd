extends TabContainer
class_name HideoutMenu

@export var tab_bar:TabContainer

@export var stash_tab_index:int
@export var stash_inventory_control:StashInventory

@export var map_select_tab_index:int

func show_stash_tab():
	tab_bar.current_tab = stash_tab_index

func show_map_select_tab():
	tab_bar.current_tab = map_select_tab_index


