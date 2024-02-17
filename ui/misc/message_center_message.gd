extends Control
class_name MessageCenterMessage

@onready var message_label:Label = $"."

func update_message(message_text:String):
	message_label.text = message_text
