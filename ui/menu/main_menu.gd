extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_demo_button_pressed():
	get_tree().root.add_child(load("res://levels/demo_level.tscn").instantiate())
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	pass # Replace with function body.


func _on_credits_button_pressed():
	pass # Replace with function body.


func _on_quit_game_button_pressed():
	get_tree().quit()
	


func _on_options_button_pressed():
	MenuManager.load_menu(MenuManager.MENU_LEVEL.OPTIONS)
