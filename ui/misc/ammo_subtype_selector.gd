extends CenterContainer
class_name AmmoSubtypeSelector

var subtype_button_scene:PackedScene = preload("res://ui/misc/sub_type_list_item.tscn")

@onready var ammo_menu = $MarginContainer/VBoxContainer

var _selecting:bool = false

func start_selection(ammo_type:AmmoType, current_subtype:AmmoSubtype, other_subtypes:Array[AmmoSubtype]):
	if !_selecting:
		_selecting = true
		self.visible = true
		
		var center_button:AmmoSubTypeListItem = subtype_button_scene.instantiate()
		center_button._ammo_type = ammo_type
		center_button._ammo_subtype = current_subtype
		ammo_menu.add_child(center_button)
		
		for ost:AmmoSubtype in other_subtypes:
			var button:AmmoSubTypeListItem = subtype_button_scene.instantiate()
			button._ammo_type = ammo_type
			button._ammo_subtype = ost
			ammo_menu.add_child(button)
			
		center_button.select()
	
func _gui_input(event):
	if _selecting and event.is_action_pressed("change_ammo_subtype"):
		accept_event()
		
