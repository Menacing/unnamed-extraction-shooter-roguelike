extends Button

@export var _ammo_type:AmmoType
@export var _ammo_subtype:AmmoSubtype



func _on_pressed() -> void:
	EventBus.ammo_type_changed.emit(_ammo_type.name, _ammo_subtype.name)
	pass # Replace with function body.
