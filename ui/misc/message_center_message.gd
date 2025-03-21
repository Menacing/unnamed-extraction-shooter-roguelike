extends Control
class_name MessageCenterMessage

@onready var message_label:RichTextLabel = $"."

func update_message(message_text:String):
	if message_label:
		message_label.text = message_text

func start_message(message_text:String, message_timeout:float):
	message_label.text = message_text
	if message_timeout > 0.0:
		var timer:Timer = Timer.new()
		timer.wait_time = message_timeout
		timer.timeout.connect(remove_message)
		self.add_child(timer)
		timer.start()
		pass

func remove_message():
	EventBus.remove_message.emit(self.name)
