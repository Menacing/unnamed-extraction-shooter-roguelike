extends MarginContainer

@export var _actor_node:Node3D
var _actor_id:int

@onready var message_scene:PackedScene = load("res://ui/misc/message_center_message.tscn")
@onready var message_box:Control = %MessageBox

@onready var effect_scene:PackedScene = load("res://ui/misc/gameplay_effect_control.tscn")
@onready var effect_box:Control = %EffectBox

func _ready() -> void:
	if _actor_node:
		_actor_id = _actor_node.get_instance_id()
	EventBus.create_message.connect(_on_create_message)
	EventBus.remove_message.connect(_on_remove_message)
	EventBus.update_message.connect(_on_update_message)
	EventBus.create_effect.connect(_on_create_effect)
	EventBus.remove_effect.connect(_on_remove_effect)

func _on_create_message(message_name:String, message_text:String, message_timeout:float):
	var message_control:MessageCenterMessage = message_scene.instantiate()
	message_control.name = message_name
	if message_timeout > 0.0:
		#TODO Wire up an auto removal
		message_box.add_child(message_control)
		message_control.start_message(message_text.to_upper(), message_timeout)
		pass
	else:
		message_box.add_child(message_control)
		message_control.update_message(message_text.to_upper())
	pass
	
func _on_remove_message(message_name):
	var message = message_box.get_node("./" + message_name)
	if message:
		message.queue_free()
	pass
	
func _on_update_message(message_name:String, message_text:String):
	var message: MessageCenterMessage = message_box.get_node(message_name)
	if message:
		message.update_message(message_text.to_upper())
	pass
	
func _on_create_effect(actor_id:int, gameplay_effect:GameplayEffect):
	if actor_id == _actor_id and gameplay_effect.visible:
		var effect_control:GameplayEffectControl = effect_scene.instantiate()
		effect_control.name = gameplay_effect.effect_name
		effect_control.set_effect_icon(gameplay_effect.display_icon)
		effect_box.add_child(effect_control)
		pass
	
func _on_remove_effect(actor_id:int, gameplay_effect:GameplayEffect):
	if actor_id == _actor_id:
		var effect_control = effect_box.get_node("./" + gameplay_effect.effect_name)
		if effect_control:
			effect_control.queue_free()

