extends Node3D

@onready var player:Player = $Player
@export var mesh:MeshInstance3D
@onready var exclusions:Array[RID] = []
var alert_color:StandardMaterial3D
var passive_color:StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready():
	alert_color = StandardMaterial3D.new()
	alert_color.albedo_color = Color(1,0,0,1)
	passive_color = StandardMaterial3D.new()
	passive_color.albedo_color = Color(1,1,1,1)
	EventBus.level_loaded.emit()
	LevelManager.emit_populate_level.call_deferred()
	var player_collider_rids = Helpers.get_all_collision_object_3d_recursive(player)
	for rid in player_collider_rids:
		exclusions.append(rid)


func _physics_process(delta):
	var material = mesh.material_override
	if player:
		var los_result = Helpers.los_to_point(mesh, player.los_check_locations, .6, exclusions, true)
		if los_result:
			mesh.material_override = alert_color
		else:
			mesh.material_override = passive_color
	else:
		mesh.material_override = passive_color
	pass
