extends Node
class_name EquipEffectComponent

@export var gameplay_effects:Array[GameplayEffect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for gameplay_effect:GameplayEffect in gameplay_effects:
		for effect in gameplay_effect.effect_lists:
			effect.effect_target_node = self.get_parent()
		EventBus.create_effect.emit(self.get_parent().get_instance_id(), gameplay_effect)


func _exit_tree() -> void:
	for gameplay_effect:GameplayEffect in gameplay_effects:
		EventBus.remove_effect.emit(self.get_parent().get_instance_id(), gameplay_effect)
