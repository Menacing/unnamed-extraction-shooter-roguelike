extends TabContainer
class_name HideoutMenu

@export var tab_bar:TabContainer

@export var stash_tab_index:int

func show_stash_tab():
	tab_bar.current_tab = stash_tab_index
