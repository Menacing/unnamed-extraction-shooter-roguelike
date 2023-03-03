extends Node3D

@export var pen_ratio = .8
@export var armor_rating: int = 6
@export var _bullet_hole_scene : PackedScene = load("res://Scenes/Bullet/Bullet_hole.tscn")
@export var _impact_hit:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	var position = col.get_position()
	var normal = col.get_normal()
	var collider = col.get_collider()
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, position])
	
	if _bullet_hole_scene:
		var bulletInst = _bullet_hole_scene.instantiate() as Node3D
		add_child(bulletInst)
		bulletInst.global_transform.origin = position
		bulletInst.look_at(normal+position,Vector3.UP)
	if _impact_hit:
		var hit_inst = _impact_hit.instantiate() as Node3D
		hit_inst.set_as_top_level(true)
		get_parent().add_child(hit_inst)
		hit_inst.global_transform.origin = position
		hit_inst.look_at(normal+position,Vector3.UP)
	
	
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
