extends ColorRect

@export var menu_music_stream:AudioStream

func _ready():
	%godot_logo.tooltip_text = Engine.get_license_text()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		go_back()

func _on_back_button_mouse_entered():
	GGS.play_sfx(GGS.SFX.MOUSE_OVER)

func _on_back_button_pressed():
	GGS.play_sfx(GGS.SFX.INTERACT)
	go_back()

func go_back():
	MenuManager.load_menu(MenuManager.previous_menu_level)
