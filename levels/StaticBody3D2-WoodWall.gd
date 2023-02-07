extends StaticBody3D

@export var pen_ratio = .8
@export var armor_rating: int = 6
@export var _bullet_hole_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	var position = col.get_position()
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, position])
	var bulletInst = _bullet_hole_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = position
	bulletInst.look_at(col.get_normal())
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
