extends Node
class_name DamageComponent

@export var pen_ratio:float = 1.0
@export var damage_multiplier := 1.0
@export var armor_rating := 0
@export var health_component:HealthComponent

signal hit_occured(damage_result:AttackResult)

func hit(damage_component:AttackComponent) -> AttackResult:
	if damage_component and damage_component.armor_penetration_rating >= armor_rating:
		var damage = damage_component.damage * damage_multiplier
		if health_component:
			health_component.apply_damage(damage)
		var damage_result = AttackResult.new(pen_ratio)
		hit_occured.emit(damage_result)
		return damage_result
	else:
		var damage_result = AttackResult.new(0.0)
		hit_occured.emit(damage_result)
		return damage_result
