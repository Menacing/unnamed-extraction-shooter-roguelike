extends Node
class_name DamageEffectComponent

@export var damage_effect_scene:PackedScene

func create_effect(ar:AttackResult):
	var effect = damage_effect_scene.instantiate()
	
	self.add_child(effect)
	#TODO align with hit normal
	#TODO pass in damage
	
	pass
