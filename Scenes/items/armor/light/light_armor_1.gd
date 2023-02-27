extends RigidBody3D

@export var pen_ratio = 1.0
@export var armor_rating: int = 6
var _durability:float = 100.0
@export var durability:float:
	set(value):
		_durability = value
		if _durability < 0:
			print("%s destroyed" % self.name)
			self.queue_free()
	get:
		return _durability


func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	var position = col.get_position()
	if pen_rating >= armor_rating:
		durability -= damage/2
		return pen_ratio
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, durability])
	else:
		durability -= damage
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, durability])
		return 0.0
