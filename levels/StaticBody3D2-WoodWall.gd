extends StaticBody3D

@export var pen_ratio = .8
@export var armor_rating: int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit(damage = 0.0, pen_rating = 0, position = Vector3.ZERO) -> float:
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, position])
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
