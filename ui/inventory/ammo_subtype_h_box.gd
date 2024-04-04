extends HBoxContainer
class_name AmmoSubtyoeHBoxControl

@export var _ammo_type:AmmoType
@export var _ammo_subtype:AmmoSubtype

@onready var subtype_name_label:Label = $SubtypeNameLabel
@onready var subtype_amount_label:Label = $SubtypeAmountLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	subtype_name_label.text = _ammo_subtype.name
	EventBus.reserve_ammo_count_changed.connect(_on_reserve_ammo_count_changed)
	pass # Replace with function body.


func _on_reserve_ammo_count_changed(ammo_type:AmmoType, ammo_subtype:AmmoSubtype, new_amount:int) -> void:
	if _ammo_type.name == ammo_type.name and _ammo_subtype.name == ammo_subtype.name:
		subtype_amount_label.text = str(new_amount)
	pass

func _on_drop_20_button_pressed() -> void:
	pass # Replace with function body.


func _on_drop_all_button_pressed() -> void:
	pass # Replace with function body.
