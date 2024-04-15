extends Control

@onready var gun:Gun = $PM52
@onready var ammo_subtype_selector:AmmoSubtypeSelector = $AmmoSubtypeSelector

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ammo_subtype_selector.start_selection(gun.get_ammo_type(), gun.current_ammo_subtype, gun.get_unselected_ammo_subtypes())
	
	pass # Replace with function body.



