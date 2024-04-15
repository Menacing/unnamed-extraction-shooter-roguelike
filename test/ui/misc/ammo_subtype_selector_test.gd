extends Control

@onready var gun:Gun = $PM52
@onready var ammo_subtype_selector:AmmoSubtypeSelector = $AmmoSubtypeSelector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _gui_input(event):
	if event.is_action_pressed("change_ammo_subtype"):
		ammo_subtype_selector.start_selection(gun.get_ammo_type(), gun.current_ammo_subtype, gun.get_unselected_ammo_subtypes())

