extends Resource
class_name GameMaterialInfo

@export_range(0.0, 1.0) var pen_ratio = 1.0
@export_range(0,10) var armor_rating: int = 0
@export var bullet_hole_scene:PackedScene
@export var impact_hit_scene:PackedScene
@export var footstep_sound:AudioStream
