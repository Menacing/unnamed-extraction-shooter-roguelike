extends HBoxContainer
class_name AmmoSubtyoeHBoxControl

@export var ammo_subtype:AmmoSubtype

@onready var subtype_name_label:Label = $SubtypeNameLabel
@onready var subtype_amount_label:Label = $SubtypeAmountLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	subtype_name_label.text = ammo_subtype.name
	
	pass # Replace with function body.
