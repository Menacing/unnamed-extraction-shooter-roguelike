extends PanelContainer

signal slot_clicked(index:int, button:int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel
@onready var durability_label: Label = $DurabilityLabel


func set_slot_data(slot_data:SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.icon
	tooltip_text = "%s\n%s" % [item_data.display_name, item_data.description_text]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()
	
	if slot_data.item_data.has_durability:
		durability_label.text = "%s%" % (slot_data.durability/slot_data.item_data.max_durability * 100)

func _on_gui_input(event: InputEvent) -> void:
	#TODO rework this to the mappable events
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT \
				or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
