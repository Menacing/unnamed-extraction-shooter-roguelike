extends RigidBody3D

var player:Player
@onready var exclusions:Array[RID] = [self]
@onready var mesh:MeshInstance3D = $MeshInstance3D
var alert_color:StandardMaterial3D
var passive_color:StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready():
	alert_color = StandardMaterial3D.new()
	alert_color.albedo_color = Color(1,0,0,1)
	passive_color = StandardMaterial3D.new()
	passive_color.albedo_color = Color(1,1,1,1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var material = mesh.material_override
	if player:
		var los_result = Helpers.los_to_point(self,player.los_check_locations,.6,exclusions)
		if los_result:
			mesh.material_override = alert_color
		else:
			mesh.material_override = passive_color
	else:
		mesh.material_override = passive_color
	pass


func _on_area_3d_body_entered(body):
	if body is Player:
		player = body
		var player_collider_rids = Helpers.get_all_collision_object_3d_recursive(player)
		for rid in player_collider_rids:
			exclusions.append(rid)


func _on_area_3d_body_exited(body):
	if body == player:
		player = null
		exclusions = [self]
