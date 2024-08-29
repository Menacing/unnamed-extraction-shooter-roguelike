extends Node
class_name DamageEffectComponent

@export var damage_effect_scene:PackedScene

func create_effect(ar:AttackResult):
	var effect:Node3D = damage_effect_scene.instantiate()
	self.add_child(effect)
	effect.global_position = ar.attack_position

	#align with hit normal
	# Calculate the rotation required to align the -Z axis with the normal
	var target_rotation = Quaternion(Vector3.FORWARD, ar.attack_normal)
	# Apply the rotation to the node
	effect.quaternion = target_rotation
	#TODO pass in damage
	
	pass
