extends VBoxContainer
class_name AmmoTypeVBoxContainer

@export var ammo_type:AmmoType

var subtype_scene:PackedScene = load("res://ui/inventory/ammo_subtype_h_box.tscn")

@onready var ammo_type_name_label:Label = $AmmoTypeHBox/AmmoTypeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammo_type_name_label.text = ammo_type.name
	for subtype:AmmoSubtype in ammo_type.sub_types:
		var subtype_control:AmmoSubtyoeHBoxControl = subtype_scene.instantiate()
		subtype_control.ammo_subtype = subtype
		add_child(subtype_control)
	
	pass # Replace with function body.


