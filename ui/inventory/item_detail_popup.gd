extends Control
class_name ItemDetailPopup

@export var parent_inventory_interface:InventoryInterface

var _inventory_data:InventoryData

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		#accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	if parent_inventory_interface and _inventory_data:
		parent_inventory_interface._disconnect_inventory_data_signals(_inventory_data)
	self.queue_free()

func set_slot_data(slot_data:SlotData) -> void:
	pass
