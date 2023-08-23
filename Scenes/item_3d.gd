extends RigidBody3D
class_name Item3D

var item_instance_id:int
var _item_instance:ItemInstance:
	get:
		return InventoryManager.get_item(item_instance_id)

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
@export_multiline var tooltip_text:String = "This is a placeholder"
var _meshes:Array[MeshInstance3D]
var meshes:Array[MeshInstance3D]:
	get:
		if _meshes:
			return _meshes
		else:
			_meshes = get_all_mesh_nodes(self)
			return _meshes


func _ready():
	assert(world_collider_path != null)
	if start_highlighted:
		set_material_overlay(item_highlight_m)
	else:
		set_material_overlay(null)

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
	world_collider.disabled = false
	self.freeze = false
	self.visible = true
	set_material_overlay(item_highlight_m)
	
	self.apply_torque_impulse(Vector3.FORWARD)
	

func picked_up():
	self.transform = Transform3D.IDENTITY
#	self.gravity_scale = 0
	world_collider.disabled = true
	self.freeze = true
	set_material_overlay(null)

	
func destroy():
	#Events.item_destroyed.emit(self)
	self.call_deferred("queue_free")

func set_stacks(amount:int):
	_item_instance.stacks = amount
