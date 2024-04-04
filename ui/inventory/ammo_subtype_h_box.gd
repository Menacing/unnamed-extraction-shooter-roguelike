extends HBoxContainer
class_name AmmoSubtypeHBoxControl

@export var _ammo_type:AmmoType
@export var _ammo_subtype:AmmoSubtype
@export var _actor_id:int

@onready var subtype_name_label:Label = $SubtypeNameLabel
@onready var subtype_amount_label:Label = $SubtypeAmountLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	subtype_name_label.text = _ammo_subtype.name
	EventBus.reserve_ammo_count_changed.connect(_on_reserve_ammo_count_changed)
	pass # Replace with function body.


func _on_reserve_ammo_count_changed(ammo_type:String, ammo_subtype:String, new_amount:int) -> void:
	if _ammo_type.name == ammo_type and _ammo_subtype.name == ammo_subtype:
		subtype_amount_label.text = str(new_amount)
	pass

func _on_drop_20_button_pressed() -> void:
	EventBus.drop_ammo.emit(_actor_id, _ammo_type.name, _ammo_subtype.name, 20)
	pass # Replace with function body.


func _on_drop_all_button_pressed() -> void:
	EventBus.drop_all_ammo.emit(_actor_id, _ammo_type.name, _ammo_subtype.name)
	pass # Replace with function body.
	
