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

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	var position = col.position
	var normal = col.normal
	var collider = col.collider
#	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, position])
	
	if _bullet_hole_scene:
		var bulletInst = _bullet_hole_scene.instantiate() as Node3D
		add_child(bulletInst)
		if normal == Vector3.UP or normal == Vector3.DOWN:
			bulletInst.look_at_from_position(position, normal, Vector3.RIGHT)
		else:
			bulletInst.look_at_from_position(position, normal)
	if _impact_hit:
		var hit_inst = _impact_hit.instantiate() as Node3D
		hit_inst.set_as_top_level(true)
		get_parent().add_child(hit_inst)
		if normal == Vector3.UP or normal == Vector3.DOWN:
			hit_inst.look_at_from_position(position, normal, Vector3.RIGHT)
		else:
			hit_inst.look_at_from_position(position, normal)

	object_hit.emit()
	if pen_rating >= armor_rating:
		return pen_ratio
	else:
		return 0.0
