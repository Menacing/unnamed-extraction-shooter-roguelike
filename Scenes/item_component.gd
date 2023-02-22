extends Node

class_name ItemComponent

enum ItemType {
	GUN,
	BACKPACK,
	MATERIAL
}
signal stack_changed(newStack:int)

@export var id:String
@export var type:ItemType
@export var icon:Texture
@export var icon_r:Texture
var _stack:int
@export var stack:int = 1:
	get:
		return _stack
	set(value):
		_stack = value
		stack_changed.emit(_stack)
@export var max_stack:int = 1
@export var column:int
@export var column_span:int
@export var row:int
@export var row_span:int
var node_id:int:
	get:
		return get_parent().get_instance_id()
	set(value):
		pass
		
@export var world_collider_path:NodePath
var _world_collider:CollisionShape3D
var world_collider:CollisionShape3D:
	get:
		if _world_collider:
			return _world_collider
		else:
			_world_collider =  get_node(world_collider_path)
			return _world_collider
@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@export var start_highlighted:bool = true
var _meshes:Array[MeshInstance3D]
var meshes:Array[MeshInstance3D]:
	get:
		if _meshes:
			return _meshes
		else:
			_meshes = get_all_mesh_nodes(get_parent())
			return _meshes


func _ready():
	if start_highlighted:
		set_material_overlay(item_highlight_m)
	else:
		set_material_overlay(null)

var idata_keys:Array = ["id",
		"type",
		"icon",
		"stack",
		"max_stack",
		"column",
		"column_span",
		"row",
		"row_span",
		"node_id"]

var idata:Dictionary:
	get:
		var dict = {}
		for key in idata_keys:
			var val = self.get(key)
			if val:
				dict[key] = val
		return dict
	set(value):
		for key in idata_keys:
			if value.has(key):
				self.set(key,value[key])
				
func get_all_mesh_nodes(node) -> Array[MeshInstance3D]:
	var mesh_nodes:Array[MeshInstance3D] =[]
	for N in node.get_children():
		if N is MeshInstance3D:
			mesh_nodes.append(N)
		if N.get_child_count() > 0:
			mesh_nodes.append_array(get_all_mesh_nodes(N))
		else:
			# Do something
			pass
	return mesh_nodes
	
func set_material_overlay(mat:Material):
	for m in meshes:
		if m != null:
			var mesh:MeshInstance3D = m
			mesh.material_overlay = mat
			
func dropped():
	var parent = get_parent()
	world_collider.disabled = false
	parent.freeze = false
	set_material_overlay(item_highlight_m)
	if parent is RigidBody3D:
		parent.apply_torque_impulse(Vector3.FORWARD)
	

func picked_up():
	get_parent().transform = Transform3D.IDENTITY
#	self.gravity_scale = 0
	world_collider.disabled = true
	get_parent().freeze = true
	set_material_overlay(null)

	
func destroy():
	var parent = self.get_parent()
	if parent:
		parent.call_deferred("queue_free")
	self.queue_free()
