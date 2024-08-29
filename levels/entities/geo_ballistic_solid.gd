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
		_hit_effect_scene = gmi.hit_effect_scene
		_footstep_sound = gmi.footstep_sound
	
	if 'game_material_info_path' in func_godot_properties:
		var path = func_godot_properties['game_material_info_path']
		if path:
			var gmi:GameMaterialInfo = load(path)
			_pen_ratio = gmi.pen_ratio
			_armor_rating = gmi.armor_rating
			_hit_effect_scene = gmi.hit_effect_scene
			_footstep_sound = gmi.footstep_sound

	#These exist for overrides
	if 'pen_ratio' in func_godot_properties:
		print("override pen_ratio: " + func_godot_properties['pen_ratio'])
		_pen_ratio = float(func_godot_properties['pen_ratio'])

	if 'armor_rating' in func_godot_properties:
		print("override armor_rating: " + func_godot_properties['armor_rating'])
		_armor_rating = int(func_godot_properties['armor_rating'])
		
	if 'hit_effect_scene_path' in func_godot_properties:
		print("override hit_effect_scene_path: " + func_godot_properties['hit_effect_scene_path'])
		_hit_effect_scene_path = func_godot_properties['hit_effect_scene_path']

	if 'footstep_sound_path' in func_godot_properties:
		print("override footstep_sound_path: " + func_godot_properties['footstep_sound_path'])
		_footstep_sound_path = func_godot_properties['footstep_sound_path']
		
	if 'transparent' in func_godot_properties:
		_transparent = func_godot_properties['transparent']
		
	set_collision_layer_value(4,!_transparent)
	
	var dc:DamageComponent = damage_component_scene.instantiate() as DamageComponent
	if dc:
		dc.percent_penetrated = _pen_ratio
		dc.armor_rating = _armor_rating
		self.add_child(dc)
		dc.owner = self.owner
	
	var dec:DamageEffectComponent = damage_effect_component_scene.instantiate() as DamageEffectComponent
	if dec:
		dec.damage_effect_scene = _hit_effect_scene
		self.add_child(dec)
		dec.owner = self.owner
	if dc is DamageComponent and dec is DamageEffectComponent:
		dc.hit_occured.connect(dec.create_effect,Object.CONNECT_PERSIST)

@export var _transparent := false
@export_range(0.0, 1.0) var _pen_ratio = 1.0
@export_range(0,10) var _armor_rating: int = 0
@export_node_path("Node3D") var _hit_effect_scene_path
@export_file var _footstep_sound_path

@export var _hit_effect_scene:PackedScene
@export var _footstep_sound:AudioStream

@export var game_material_info_list:GameMaterialInfoList = preload('res://levels/game_material_info/uesrl_game_material_info_list.tres')

var damage_component_scene:PackedScene = preload("res://components/damage_component/damage_component.tscn")
var damage_effect_component_scene:PackedScene = preload("res://components/damage_effect_component/damage_effect_component.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	if _footstep_sound_path:
		_footstep_sound = load(_footstep_sound_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
	pass

