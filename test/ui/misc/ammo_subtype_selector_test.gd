extends Control

@onready var gun:Gun = $PM52
@onready var ammo_subtype_selector:AmmoSubtypeSelector = $AmmoSubtypeSelector

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.ammo_type_changed.connect(_on_ammo_type_changed)
	pass # Replace with function body.


func _unhandled_input(event):
	if event.is_action_pressed("change_ammo_subtype"):
		ammo_subtype_selector.start_selection(gun.get_ammo_type(), gun.current_ammo_subtype, gun.get_unselected_ammo_subtypes())


func _on_ammo_type_changed(new_type:String, new_subtype:String):
	ammo_subtype_selector.end_selection()
