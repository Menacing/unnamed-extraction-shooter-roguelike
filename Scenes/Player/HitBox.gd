extends CharacterBody3D
class_name PlayerHitBox

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.position])
	Events.took_damage.emit(damage, hit_origin)
	return pen_ratio
