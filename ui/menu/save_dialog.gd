extends CenterContainer

@onready var save_file_name_box:TextEdit = %SaveFileNameInput
@onready var confirm_button:Button = %ConfirmButton

func _gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.queue_free()


func _on_cancel_button_pressed():
	self.queue_free()


func _on_confirm_button_pressed():
	var save_file_name = save_file_name_box.text
	SaveManager.save_game(save_file_name)
	self.queue_free()

func _on_save_file_name_input_text_changed():
	if save_file_name_box.text.length() >= 3:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true
