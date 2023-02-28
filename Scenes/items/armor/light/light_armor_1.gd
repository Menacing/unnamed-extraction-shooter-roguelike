extends RigidBody3D

@export var pen_ratio = 1.0
@export var armor_rating: int = 6
@onready var item_comp:ItemComponent = $ItemComponent


func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	var position = col.get_position()
	if pen_rating >= armor_rating:
		item_comp.durability -= damage/2
		return pen_ratio
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, item_comp.durability])
	else:
		item_comp.durability -= damage
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, item_comp.durability])
		return 0.0
