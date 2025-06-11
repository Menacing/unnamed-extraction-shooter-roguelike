extends Resource
class_name GameplayEffect

@export var display_icon:Texture2D
@export var effect_name:String
@export var effect_lists:Array[GameplayEffectList]
@export var visible:bool = true


func apply_to(node:Node):
	for effect in effect_lists:
		effect.effect_target_node = node
	EventBus.create_effect.emit(node.get_instance_id(), self)

func remove_from(node:Node):
	for effect in effect_lists:
		effect.effect_target_node = node
	EventBus.remove_effect.emit(node.get_instance_id(), self)
