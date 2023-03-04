extends Node3D

signal object_hit()

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

func _on_hit(damage = 0.0, pen_rating = 0, col:CollisionInformation = null) -> float:
	var position = col.position
	var normal = col.normal
	var collider = col.collider
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

	object_hit.emit()
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
