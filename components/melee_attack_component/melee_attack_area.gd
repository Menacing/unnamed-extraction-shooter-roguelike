extends Area3D

@onready var attack_component: AttackComponent = %AttackComponent

func _on_area_entered(area: Area3D) -> void:
	var damage_component:DamageComponent = Helpers.get_component_of_type(area, DamageComponent)
	if damage_component:
		damage_component.hit(attack_component)
		pass
	
	pass # Replace with function body.
