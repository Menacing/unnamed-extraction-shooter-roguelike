extends Control


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		MenuManager.load_menu(MenuManager.previous_menu_level)
