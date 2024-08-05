extends Node

enum MENU_LEVEL {
	NONE,
	MAIN,
	PAUSE,
	OPTIONS,
	CREDITS,
	EXTRACTED,
	DIED,
	RUN_BEGIN
}

var menus = {
	MENU_LEVEL.MAIN : preload("res://ui/menu/main_menu.tscn").instantiate(),
	MENU_LEVEL.PAUSE : preload("res://ui/menu/pause.tscn").instantiate(),
	MENU_LEVEL.OPTIONS: preload("res://ui/menu/options_menu.tscn").instantiate(),
	MENU_LEVEL.CREDITS: preload("res://ui/menu/credits/credits.tscn").instantiate(),
	MENU_LEVEL.EXTRACTED: preload("res://ui/menu/extraction_menu_temp.tscn").instantiate(),
	MENU_LEVEL.DIED: preload("res://ui/menu/death_menu_temp.tscn").instantiate(),
	MENU_LEVEL.RUN_BEGIN: preload("res://ui/menu/run_start_menu.tscn").instantiate()
}

var current_menu:Node = null
var current_scene:Node = null
var current_menu_level:MENU_LEVEL = MENU_LEVEL.NONE
var previous_menu_level:MENU_LEVEL = MENU_LEVEL.NONE
var menu_layer:int = 15
var menu_material = load("res://ui/menu/vhs_pause_material.tres")
@onready var menu_music_player:AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	menu_music_player.name = "MenuMusicPlayer"
	menu_music_player.set_bus("Music")
	self.add_child(menu_music_player)

func load_menu(menuLevel:MENU_LEVEL):
	previous_menu_level = current_menu_level
	call_deferred("_deffered_load_menu", menuLevel)
	
func _deffered_load_menu(menuLevel:MENU_LEVEL):
	var container = current_scene.find_child("menu", false, false) as CanvasLayer
	if menuLevel == MENU_LEVEL.NONE:
		if container:
			container.visible = false
		current_menu = null
		menu_music_player.stop()
		return

	if not container:
		var menunode = CanvasLayer.new()
		menunode.set_name("menu")
		menunode.process_mode = Node.PROCESS_MODE_ALWAYS
		menunode.layer = menu_layer
		current_scene.add_child(menunode)
		container = menunode
	#clear the current menu item/s
	for location in container.get_children():
		container.remove_child(location)
		if location.has_method("menu_deactivated"):
			location.menu_deactivated()
	#add our selected menu
	#replace the current menus instance with the new ones
	current_menu = menus[menuLevel]
	if menu_material and current_menu is Control:
		current_menu.material = menu_material
	current_menu_level = menuLevel
	container.add_child(current_menu)
	container.visible = true
	if current_menu.has_method("menu_activated"):
		current_menu.menu_activated()
	if "menu_music_stream" in current_menu:
		var menu_music_stream = current_menu.menu_music_stream as AudioStream
		if menu_music_stream:
			if menu_music_player.stream != menu_music_stream:
				menu_music_player.stream = menu_music_stream
				menu_music_player.play()
			elif !menu_music_player.playing:
				menu_music_player.play()
	else:
		menu_music_player.stop()
