@tool
class_name GeoBallisticDoor
extends GeoBallisticMover

@export var _target_name:String
@export var _hinge:Node3D

func update_properties() -> void:
	super()
	if 'targetname' in properties:
		_target_name = properties.targetname

func _process(delta: float) -> void:
	if _hinge:
		_hinge.transform = _hinge.transform.interpolate_with(target_transform, speed * delta)
	else:
		super(delta)

func _ready() -> void:
	super()
	if _target_name:
		var hinge_node = get_node("%"+_target_name)
		if hinge_node:
			_hinge = hinge_node
			call_deferred("reparent_hinge")


func reparent_hinge():
	#calculate new offset for door
	var new_door_offset = self.global_transform.origin - _hinge.global_transform.origin
	#reparent
	Helpers.force_parent(self, _hinge)
	#set new door transform
	self.transform.origin = new_door_offset
	#set target values
	base_transform = _hinge.transform
	target_transform = base_transform