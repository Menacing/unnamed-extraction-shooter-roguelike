extends CSGBox3D


func _on_damage_component_hit_occured(attack_result):
	$LootFiestaComponent.fiesta()
	pass # Replace with function body.
