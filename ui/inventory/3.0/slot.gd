extends PanelContainer

signal slot_clicked(index:int, event:InputEvent)

@onready var quantity_label: Label = $QuantityLabel
@onready var durability_label: Label = $DurabilityLabel
@onready var background_sprite_2d: Sprite2D = $BackgroundSprite2D
@onready var icon_sprite_2d: Sprite2D = $IconSprite2D

const cell_size:int = 64

func set_slot_data(slot_data:SlotData, force_display = false) -> void:
	if slot_data and (force_display or slot_data.root_index == get_index()):
		var item_data = slot_data.item_data
		set_slot_texture(slot_data)
		tooltip_text = "%s\n%s" % [item_data.display_name, item_data.description_text]
		
		if slot_data.quantity > 1:
			quantity_label.text = "x%s" % slot_data.quantity
			quantity_label.show()
		else:
			quantity_label.hide()
		
		if slot_data.item_data.has_durability:
			durability_label.text = "%s%" % (slot_data.durability/slot_data.item_data.max_durability * 100)
			durability_label.show()
		else:
			durability_label.hide()
	else:
		background_sprite_2d.hide()
		icon_sprite_2d.hide()
		quantity_label.hide()
		durability_label.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_grab") or event.is_action_pressed("place_single_of_stack"):
		slot_clicked.emit(get_index(), event)

func set_slot_texture(slot_data:SlotData):
	var item_data:ItemInformation = slot_data.item_data
	
	icon_sprite_2d.texture = item_data.icon
	var target_width = item_data.column_span * cell_size
	var target_height = item_data.row_span * cell_size
	
	var icon_tex_size = icon_sprite_2d.texture.get_size()
	var icon_target_width_scale = target_width / icon_tex_size.x
	var icon_target_height_scale = target_height / icon_tex_size.y
	
	icon_sprite_2d.scale = Vector2(icon_target_width_scale, icon_target_height_scale)
	icon_sprite_2d.show()
	
	var background_tex_size = background_sprite_2d.texture.get_size()
	var background_target_width_scale = target_width / background_tex_size.x
	var background_target_height_scale = target_height / background_tex_size.y
	
	background_sprite_2d.scale = Vector2(background_target_width_scale, background_target_height_scale)
	background_sprite_2d.show()
	
	self.z_index = 1
