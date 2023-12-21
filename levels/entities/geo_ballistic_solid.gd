@tool
class_name GeoBallisticSolid
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
	
	if 'game_material_info_path' in properties:
		
		var gmi:GameMaterialInfo = load(properties['game_material_info_path'])
		_pen_ratio = gmi.pen_ratio
		_armor_rating = gmi.armor_rating
		_bullet_hole_scene = gmi.bullet_hole_scene
		_impact_hit_scene = gmi.impact_hit_scene
		_footstep_sound = gmi.footstep_sound

	#These exist for overrides
	if 'pen_ratio' in properties:
		print("override pen_ratio: " + properties['pen_ratio'])
		_pen_ratio = float(properties['pen_ratio'])

	if 'armor_rating' in properties:
		print("override armor_rating: " + properties['armor_rating'])
		_armor_rating = int(properties['armor_rating'])
		
	if 'bullet_hole_scene_path' in properties:
		print("override bullet_hole_scene_path: " + properties['bullet_hole_scene_path'])
		_bullet_hole_scene_path = properties['bullet_hole_scene_path']
		
	if 'impact_hit_scene_path' in properties:
		print("override impact_hit_scene_path: " + properties['impact_hit_scene_path'])
		_impact_hit_scene_path = properties['impact_hit_scene_path']

	if 'footstep_sound_path' in properties:
		print("override footstep_sound_path: " + properties['footstep_sound_path'])
		_footstep_sound_path = properties['footstep_sound_path']

@export_range(0.0, 1.0) var _pen_ratio = 1.0
@export_range(0,10) var _armor_rating: int = 0
@export_node_path("Node3D") var _bullet_hole_scene_path
@export_node_path("Node3D") var _impact_hit_scene_path
@export_file var _footstep_sound_path

@export var _bullet_hole_scene:PackedScene
@export var _impact_hit_scene:PackedScene
@export var _footstep_sound:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	if _bullet_hole_scene_path:
		_bullet_hole_scene = load(_bullet_hole_scene_path)
	if _impact_hit_scene_path:
		_impact_hit_scene = load(_impact_hit_scene_path)
	if _footstep_sound_path:
		_footstep_sound = load(_footstep_sound_path)


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
	if pen_rating >= _armor_rating:
		return _pen_ratio
	else:
		return 0.0
