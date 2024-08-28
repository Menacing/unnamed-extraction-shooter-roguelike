extends Node
class_name DamageComponent

##Percentage of damage that remains after passing through object if penetrated
@export var percent_penetrated:float = 1.0
@export var damage_multiplier := 1.0
@export var armor_rating := 0
##Percentage of damage that still applies even if attack doesn't penetrate
@export var damage_transmission_percent:float = 0.0
@export var location_type:HealthComponent.HEALTH_LOCATION

@export var armor_damage_component:DamageComponent

signal hit_occured(attack_result:AttackResult)

func hit(attack_component:AttackComponent) -> AttackResult:
	if attack_component:
		var damage_to_apply = attack_component.damage
		# delgate hit to armor first
		if armor_damage_component:
			var armor_hit_result:AttackResult = armor_damage_component.hit(attack_component)
			damage_to_apply = damage_to_apply * armor_hit_result.percent_penetrated
		
		#if penetrates armor, do damage and return penetration ratio
		if  attack_component.armor_penetration_rating >= armor_rating:
			var damage = damage_to_apply * damage_multiplier
			var attack_result = AttackResult.new(percent_penetrated)
			attack_result._map_from_attack_component(attack_component)
			attack_result.damage = damage
			hit_occured.emit(attack_result)
			return attack_result
		#else damage is stopped, return 0 pen percent
		else:
			var attack_result = AttackResult.new(0.0)
			attack_result._map_from_attack_component(attack_component)
			attack_result.damage = damage_to_apply * damage_multiplier * damage_transmission_percent
			hit_occured.emit(attack_result)
			return attack_result
	else:
		var attack_result = AttackResult.new(0.0)
		hit_occured.emit(attack_result)
		return attack_result

func _on_armor_equipped(armor:BodyArmor):
	var damage_component:DamageComponent = Helpers.get_component_of_type(armor, DamageComponent)
	if damage_component and armor.armored_locations.has(location_type):
		armor_damage_component = damage_component
		
func _on_armor_unequipped(armor:BodyArmor):
	if armor.armored_locations.has(location_type):
		armor_damage_component = null
