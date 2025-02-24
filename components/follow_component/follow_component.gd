extends Node
## Add as a child node of a Node3D to make it follow another Node3D
class_name FollowComponent

@export var node_to_follow:Node3D

var _parent_node:Node3D

func _ready() -> void:
	if get_parent() is Node3D:
		_parent_node = get_parent()
	else:
		printerr("Parent is not a Node3D")
	
	if !node_to_follow:
		printerr("No node to follow")

func _process(delta: float) -> void:
	_parent_node.global_position = node_to_follow.global_position
