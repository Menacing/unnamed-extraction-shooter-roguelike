extends Node

signal took_damage(damage:float)
@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.get_position()])
	emit_signal("took_damage", damage)
	return pen_ratio
