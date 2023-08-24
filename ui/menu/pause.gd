extends ColorRect

@onready var resume_button:Button = find_child("resume_button")
@onready var quit_button:Button = find_child("quit_game_button")
@onready var options_button:Button = find_child("options_button")

var original_mouse_mode:Input.MouseMode

# Called when the node enters the scene tree for the first time.
func _ready():
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	EventBus.pause.connect(pause)
	options_button.pressed.connect(_on_options_pressed)
	visibility_changed.connect(_on_visibility_changed)
	pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func unpause():
	get_tree().paused = false
	Input.mouse_mode = original_mouse_mode
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
	
func pause():
	get_tree().paused = true
	original_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_options_pressed():
	MenuManager.load_menu(MenuManager.MENU_LEVEL.OPTIONS)
	
func _on_visibility_changed():
	if self.is_visible_in_tree():
		pause()
	else:
		unpause()
	pass
