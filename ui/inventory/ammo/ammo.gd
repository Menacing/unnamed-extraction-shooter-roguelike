extends MarginContainer

var ammo_type_control_scene:PackedScene = load("res://ui/inventory/ammo/ammo_type_vbox_container.tscn")
var spacer_control_scene:PackedScene = load("res://ui/inventory/ammo/amm_h_separator.tscn")

@onready var vbox:VBoxContainer = $ScrollContainer/VBoxContainer
@export var _actor_node:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ammo_types:Array[AmmoType] = AmmoLoader.get_ammo_types()
	for at:AmmoType in ammo_types:
		var ammo_type_control:AmmoTypeVBoxContainer = ammo_type_control_scene.instantiate()
		ammo_type_control.ammo_type = at
		ammo_type_control._actor_node = _actor_node
		var spacer_control = spacer_control_scene.instantiate()
		vbox.add_child(ammo_type_control)
		vbox.add_child(spacer_control)
