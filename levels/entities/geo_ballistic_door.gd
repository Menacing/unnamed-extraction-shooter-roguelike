@tool
class_name GeoBallisticDoor
extends GeoBallisticMover

@export var _target_name:String
@export var _hinge:Node3D

func _func_godot_apply_properties(entity_properties: Dictionary):
	super(entity_properties)
	if 'targetname' in func_godot_properties:
		_target_name = func_godot_properties.targetname
		self.name = func_godot_properties.targetname
		self.unique_name_in_owner = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _hinge:
		_hinge.transform = _hinge.transform.interpolate_with(target_transform, speed * delta)
	else:
		super(delta)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()

func open_door():
	moved = true
	play_motion()
	
func close_door():
	moved = false
	play_motion()
