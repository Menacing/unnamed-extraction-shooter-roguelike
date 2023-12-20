@tool
class_name BallisticEntity
extends StaticBody3D

signal object_hit()

@export var properties: Dictionary :
	get:
		return properties
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

func update_properties():
	if 'pen_ratio' in properties:
		pen_ratio = properties['pen_ratio']

	if 'armor_rating' in properties:
		armor_rating = properties.armor_rating
		
	if 'bullet_hole_scene_path' in properties:
		bullet_hole_scene_path = properties.bullet_hole_scene_path
		
	if 'impact_hit_scene_path' in properties:
		impact_hit_scene_path = properties.impact_hit_scene_path

@export_range(0.0, 1.0) var pen_ratio = 1.0
@export_range(0,10) var armor_rating: int = 0
@export_node_path("Node3D") var bullet_hole_scene_path
@export_node_path("Node3D") var impact_hit_scene_path

var _bullet_hole_scene:PackedScene
var _impact_hit_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	_bullet_hole_scene = load(bullet_hole_scene_path)
	_impact_hit_scene = load(impact_hit_scene_path)


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
	if _impact_hit_scene:
		var hit_inst = _impact_hit_scene.instantiate() as Node3D
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
