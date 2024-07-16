extends ColorRect

@onready var resume_button:Button = %resume_button
@onready var quit_button:Button = %quit_game_button
@onready var options_button:Button = %options_button

@onready var save_dialog_scene:PackedScene = load("res://ui/menu/save_dialog.tscn")

@export var menu_music_stream:AudioStream

var original_mouse_mode:Input.MouseMode

# Called when the node enters the scene tree for the first time.
func _ready():
	original_mouse_mode = Input.mouse_mode
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	EventBus.pause.connect(pause)
	options_button.pressed.connect(_on_options_pressed)
	visibility_changed.connect(_on_visibility_changed)
	pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func unpause():
	get_tree().paused = false
	Input.mouse_mode = original_mouse_mode
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	
func pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_options_pressed():
	MenuManager.load_menu(MenuManager.MENU_LEVEL.OPTIONS)
	
func _on_visibility_changed():
	if self.is_visible_in_tree():
		pause()
	else:
		unpause()
	pass


func _on_save_button_pressed():
	var save_dialog = save_dialog_scene.instantiate()
	get_parent().add_child(save_dialog)
	save_dialog.top_level = true

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
	pass # Replace with function body.

func _on_load_dialog_file_selected(path:String):
	SaveManager.load_game(path)
	unpause()
	pass
