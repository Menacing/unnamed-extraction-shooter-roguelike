extends Item3D
class_name BodyArmor

@export var pen_ratio = 1.0
@export var armor_rating: int = 6

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	if pen_rating >= armor_rating:
		_item_instance.durability -= damage/2
		return pen_ratio
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, _item_instance.durability])
	else:
		_item_instance.durability -= damage
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, _item_instance.durability])
		return 0.0
