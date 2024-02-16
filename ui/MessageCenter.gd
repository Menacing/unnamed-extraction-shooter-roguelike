extends MarginContainer

@onready var message_scene:PackedScene = load("res://ui/misc/message_center_message.tscn")
@onready var message_box:Control = $VBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.create_message.connecct(_on_create_message)
	EventBus.remove_message.connect(_on_remove_message)
	EventBus.update_message.connect(_on_update_message)
	pass # Replace with function body.


func _on_create_message(message_name:String, message_text:String, message_timeout:int):
	var message_control:MessageCenterMessage = message_scene.instantiate()
	message_control.name = message_name
	if message_timeout>=1:
		#TODO Wire up an auto removal
		pass
	else:
		message_box.add_child(message_control)
		message_control.update_message(message_text)
	pass
	
func _on_remove_message(message_name):
	var message = message_box.get_node(message_name)
	if message:
		message.queue_free()
	pass
	
func _on_update_message(message_name:String, message_text:String):
	var message: MessageCenterMessage = message_box.get_node(message_name)
	if message:
		message.update_message(message_text)
	pass
	

