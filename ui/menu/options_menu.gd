extends Control


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		go_back()

func _on_back_button_pressed():
	go_back()

func go_back():
	MenuManager.load_menu(MenuManager.previous_menu_level)

func _on_option_tab_container_tab_hovered(tab):
	GGS.play_sfx(GGS.SFX.MOUSE_OVER)
	pass # Replace with function body.

func _on_option_tab_container_tab_clicked(tab):
	GGS.play_sfx(GGS.SFX.INTERACT)
	pass # Replace with function body.
