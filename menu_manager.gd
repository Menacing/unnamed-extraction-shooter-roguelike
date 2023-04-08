extends Node

enum MENU_LEVEL {
	NONE,
	PAUSE,
	OPTIONS
}

var menus = {
	MENU_LEVEL.PAUSE : preload("res://ui/menu/pause.tscn").instantiate(),
	MENU_LEVEL.OPTIONS: preload("res://ui/menu/options_menu.tscn").instantiate()
}

var current_menu:Node = null
var current_scene:Node = null
var current_menu_level:MENU_LEVEL = MENU_LEVEL.NONE
var previous_menu_level:MENU_LEVEL = MENU_LEVEL.NONE

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func load_menu(menuLevel:MENU_LEVEL):
	previous_menu_level = current_menu_level
	call_deferred("_deffered_load_menu", menuLevel)
	
func _deffered_load_menu(menuLevel:MENU_LEVEL):
	var container = current_scene.find_child("menu", false, false) as CanvasLayer
	if menuLevel == MENU_LEVEL.NONE:
		if container:
			container.visible = false
		current_menu = null
		return

	if not container:
		var menunode = CanvasLayer.new()
		menunode.set_name("menu")
		menunode.process_mode = Node.PROCESS_MODE_ALWAYS
		current_scene.add_child(menunode)
		container = menunode
	#clear the current menu item/s
	for location in container.get_children():
		container.remove_child(location)
	#add our selected menu
	#replace the current menus instance with the new ones
	current_menu = menus[menuLevel]
	current_menu_level = menuLevel
	container.add_child(current_menu)
	container.visible = true
