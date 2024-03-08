extends MarginContainer

var ammo_type_control_scene:PackedScene = load("res://ui/inventory/ammo_type_vbox_container.tscn")
var spacer_control_scene:PackedScene = load("res://ui/inventory/amm_h_separator.tscn")

@onready var vbox:VBoxContainer = $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ammo_types:Array[AmmoType] = AmmoLoader.get_ammo_types()
	for at:AmmoType in ammo_types:
		var ammo_type_control:AmmoTypeVBoxContainer = ammo_type_control_scene.instantiate()
		ammo_type_control.ammo_type = at
		var spacer_control = spacer_control_scene.instantiate()
		vbox.add_child(ammo_type_control)
		vbox.add_child(spacer_control)


