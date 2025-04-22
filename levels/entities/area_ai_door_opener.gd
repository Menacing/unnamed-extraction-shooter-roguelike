extends Area3D
class_name AreaAIDoorOpener

@export var door:GeoBallisticDoor

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body:Node3D) -> void:
	if body is Enemy and door:
		door.open_door()
		pass
	pass
		
func _on_body_exited(body:Node3D) -> void:
	var bodies = get_overlapping_bodies()
	
	for ebody in bodies:
		if ebody is Enemy:
			#Enemy still in area
			return
	
	#No enemies remain in area
	if door:
		door.close_door()
	pass
