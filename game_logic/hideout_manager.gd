extends Node

@export var _hideout_menu_scene:PackedScene = load("res://ui/hideout_menu.tscn")

@onready var hideout_menu:HideoutMenu = _hideout_menu_scene.instantiate()

var in_hideout:bool = false

func show_hideout_menu():
	EventBus.add_control_to_HUD.emit(hideout_menu)
	
func hide_hideout_menu():
	EventBus.remove_control_from_HUD.emit(hideout_menu)
