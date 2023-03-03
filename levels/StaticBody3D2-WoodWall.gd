extends StaticBody3D

@export var pen_ratio = .8
@export var armor_rating: int = 6
@export var _bullet_hole_scene : PackedScene
@export var _impact_hit:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	var position = col.get_position()
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, position])
	
	if _bullet_hole_scene:
		var bulletInst = _bullet_hole_scene.instantiate() as Node3D
		bulletInst.set_as_top_level(true)
		get_parent().add_child(bulletInst)
		bulletInst.global_transform.origin = position
		bulletInst.look_at(col.get_normal())
	if _impact_hit:
		var hit_inst = _impact_hit.instantiate() as Node3D
		hit_inst.set_as_top_level(true)
		get_parent().add_child(hit_inst)
		hit_inst.global_transform.origin = position
		hit_inst.look_at(col.get_normal())
	
	
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
