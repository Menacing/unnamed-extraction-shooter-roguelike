extends ColorRect

var original_mouse_mode:Input.MouseMode

func _ready():
	pass

func menu_activated():
	var death_message:ColorRect = $"."
	var tween = get_tree().create_tween()
	tween.tween_property(death_message, "modulate", Color.WHITE, 6.0)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_callback(pause)


func _on_start_demo_button_pressed():
	get_tree().call_group("level", "queue_free")
	unpause()
	MenuManager.load_menu(MenuManager.MENU_LEVEL.MAIN)
	pass # Replace with function body.


func _on_quit_game_button_pressed():
	get_tree().quit()
	
func unpause():
	get_tree().paused = false
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	
func pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
