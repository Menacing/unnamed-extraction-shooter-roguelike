@tool
class_name GeoBallisticSolid
extends CollisionObject3D

signal object_hit()

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	
	if 'game_material_info' in func_godot_properties:
		#determine gmi path
		var gmi:GameMaterialInfo = game_material_info_list.game_material_infos[int(func_godot_properties['game_material_info'])]
		_pen_ratio = gmi.pen_ratio
		_armor_rating = gmi.armor_rating
		_bullet_hole_scene = gmi.bullet_hole_scene
		_impact_hit_scene = gmi.impact_hit_scene
		_footstep_sound = gmi.footstep_sound
	
	if 'game_material_info_path' in func_godot_properties:
		var path = func_godot_properties['game_material_info_path']
		if path:
			var gmi:GameMaterialInfo = load(path)
			_pen_ratio = gmi.pen_ratio
			_armor_rating = gmi.armor_rating
			_bullet_hole_scene = gmi.bullet_hole_scene
			_impact_hit_scene = gmi.impact_hit_scene
			_footstep_sound = gmi.footstep_sound

	#These exist for overrides
	if 'pen_ratio' in func_godot_properties:
		print("override pen_ratio: " + func_godot_properties['pen_ratio'])
		_pen_ratio = float(func_godot_properties['pen_ratio'])

	if 'armor_rating' in func_godot_properties:
		print("override armor_rating: " + func_godot_properties['armor_rating'])
		_armor_rating = int(func_godot_properties['armor_rating'])
		
	if 'bullet_hole_scene_path' in func_godot_properties:
		print("override bullet_hole_scene_path: " + func_godot_properties['bullet_hole_scene_path'])
		_bullet_hole_scene_path = func_godot_properties['bullet_hole_scene_path']
		
	if 'impact_hit_scene_path' in func_godot_properties:
		print("override impact_hit_scene_path: " + func_godot_properties['impact_hit_scene_path'])
		_impact_hit_scene_path = func_godot_properties['impact_hit_scene_path']

	if 'footstep_sound_path' in func_godot_properties:
		print("override footstep_sound_path: " + func_godot_properties['footstep_sound_path'])
		_footstep_sound_path = func_godot_properties['footstep_sound_path']
		
	if 'transparent' in func_godot_properties:
		_transparent = func_godot_properties['transparent']
		
	set_collision_layer_value(4,!_transparent)

@export var _transparent := false
@export_range(0.0, 1.0) var _pen_ratio = 1.0
@export_range(0,10) var _armor_rating: int = 0
@export_node_path("Node3D") var _bullet_hole_scene_path
@export_node_path("Node3D") var _impact_hit_scene_path
@export_file var _footstep_sound_path

@export var _bullet_hole_scene:PackedScene
@export var _impact_hit_scene:PackedScene
@export var _footstep_sound:AudioStream

@export var game_material_info_list:GameMaterialInfoList = preload('res://levels/game_material_info/uesrl_game_material_info_list.tres')

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	if _bullet_hole_scene_path:
		_bullet_hole_scene = load(_bullet_hole_scene_path)
	if _impact_hit_scene_path:
		_impact_hit_scene = load(_impact_hit_scene_path)
	if _footstep_sound_path:
		_footstep_sound = load(_footstep_sound_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
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
