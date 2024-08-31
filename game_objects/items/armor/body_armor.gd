extends Item3D
class_name BodyArmor

@export var armored_locations:Array[HealthComponent.HEALTH_LOCATION]

func _on_damage_component_hit_occured(attack_result:AttackResult):
	pass
	#get_item_instance().durability -= attack_result.damage
