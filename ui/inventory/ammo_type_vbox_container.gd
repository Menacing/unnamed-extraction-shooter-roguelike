extends VBoxContainer
class_name AmmoTypeVBoxContainer

@export var ammo_type:AmmoType

var subtype_scene:PackedScene = load("res://ui/inventory/ammo_subtype_h_box.tscn")

@onready var ammo_type_name_label:Label = $AmmoTypeHBox/AmmoTypeLabel
@onready var ammo_type_texture_rect:TextureRect = $AmmoTypeHBox/AmmoTypeDisplayIcon

@export var _actor_node:Node3D
var _actor_id:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _actor_node:
		_actor_id = _actor_node.get_instance_id()
	ammo_type_name_label.text = ammo_type.name
	if ammo_type.display_icon:
		ammo_type_texture_rect.texture = ammo_type.display_icon
	for subtype:AmmoSubtype in ammo_type.sub_types:
		var subtype_control:AmmoSubtypeHBoxControl = subtype_scene.instantiate()
		subtype_control._ammo_type = ammo_type
		subtype_control._ammo_subtype = subtype
		subtype_control._actor_node = _actor_node
		add_child(subtype_control)
		
	pass # Replace with function body.
