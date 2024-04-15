extends CenterContainer
class_name AmmoSubtypeSelector

var subtype_button_scene:PackedScene = preload("res://ui/misc/sub_type_button.tscn")

@onready var ammo_menu = $VBoxContainer

func start_selection(ammo_type:AmmoType, current_subtype:AmmoSubtype, other_subtypes:Array[AmmoSubtype]):
	self.visible = true
	
	var center_button:AmmoSubTypeButton = subtype_button_scene.instantiate()
	center_button._ammo_type = ammo_type
	center_button._ammo_subtype = current_subtype
	ammo_menu.add_child(center_button)
	ammo_menu.center_node = center_button
	
	for ost:AmmoSubtype in other_subtypes:
		var button:AmmoSubTypeButton = subtype_button_scene.instantiate()
		button._ammo_type = ammo_type
		button._ammo_subtype = ost
		ammo_menu.add_child(center_button)
