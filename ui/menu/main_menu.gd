extends ColorRect

@export var menu_music_stream:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_start_demo_button_pressed():
	await LevelManager.load_level_async("res://levels/biomes/science/easy/maps/lab_1.tscn", true)
	#get_tree().root.add_child(load("res://levels/biomes/science/easy/maps/lab_1.tscn").instantiate())
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	pass # Replace with function body.

func _on_credits_button_pressed():
	MenuManager.load_menu(MenuManager.MENU_LEVEL.CREDITS)

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	MenuManager.load_menu(MenuManager.MENU_LEVEL.OPTIONS)
	

func _on_load_button_pressed():
	var load_dialog = FileDialog.new()
	load_dialog.access = FileDialog.ACCESS_USERDATA
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.set_filters(PackedStringArray(["*.tres ; Save Files"]))
	load_dialog.file_selected.connect(_on_load_dialog_file_selected)
	load_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	load_dialog.min_size = Vector2i(400,500)
	self.add_child(load_dialog)
	load_dialog.show()

func _on_load_dialog_file_selected(path:String):
	SaveManager.load_game(path)
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	pass
