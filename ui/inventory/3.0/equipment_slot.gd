extends Panel

signal equipment_slot_clicked(slot_name:String, event:InputEvent)

const cell_size:int = 48
@export var cell_margin:int = 0
@onready var background_icon_texture_rect: TextureRect = $MarginContainer/BackgroundIconTextureRect
@onready var icon_sprite_2d: Sprite2D = $IconSprite2D
@onready var background_sprite_2d: Sprite2D = $BackgroundSprite2D
@onready var quantity_label: Label = $QuantityLabel
@onready var durability_label: Label = $DurabilityLabel
@onready var margin_container: MarginContainer = $MarginContainer
@export var slot_name:String

func set_slot_data(equipment_slot:EquipmentSlot, force_display = false) -> void:
	
	background_icon_texture_rect.texture = equipment_slot.background_icon
	
	# This code sample assumes the current script is extending MarginContainer.
	var margin_value = equipment_slot.slot_width * cell_size / 4
	margin_container.add_theme_constant_override("margin_top", margin_value)
	margin_container.add_theme_constant_override("margin_left", margin_value)
	margin_container.add_theme_constant_override("margin_bottom", margin_value)
	margin_container.add_theme_constant_override("margin_right", margin_value)

	self.custom_minimum_size = Vector2(equipment_slot.slot_width * cell_size, equipment_slot.slot_height * cell_size)
	slot_name = equipment_slot.slot_name
	
	if equipment_slot.slot_data:
		if slot_name == null or slot_name == '':
			pass
		var item_data = equipment_slot.slot_data.item_data
		set_slot_texture(equipment_slot.slot_data)
		tooltip_text = "%s\n%s" % [item_data.display_name, item_data.description_text]
		
		if equipment_slot.slot_data.quantity > 1:
			quantity_label.text = "x%s" % equipment_slot.slot_data.quantity
			quantity_label.show()
		else:
			quantity_label.hide()
		
		if equipment_slot.slot_data.item_data.has_durability:
			durability_label.text = "%s%%" % (equipment_slot.slot_data.durability/equipment_slot.slot_data.item_data.max_durability * 100)
			durability_label.show()
		else:
			durability_label.hide()
	else:
		background_sprite_2d.hide()
		icon_sprite_2d.hide()
		quantity_label.hide()
		durability_label.hide()
	pass

func _convert_cells_to_pixels(number_cells:int):
	return (number_cells * cell_size) + ((number_cells-1) * cell_margin)

func set_slot_texture(slot_data:SlotData):
	var item_data:ItemInformation = slot_data.item_data
	
	icon_sprite_2d.texture = item_data.icon
	
	var target_width = _convert_cells_to_pixels(slot_data.get_width())
	var target_height = _convert_cells_to_pixels(slot_data.get_height())
	
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


func _on_resized() -> void:
	if icon_sprite_2d:
		icon_sprite_2d.position.x = self.size.x / 2
		icon_sprite_2d.position.y = self.size.y / 2
	
	if background_sprite_2d:
		background_sprite_2d.position.x = self.size.x / 2
		background_sprite_2d.position.y = self.size.y / 2


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_grab") or event.is_action_pressed("openContextMenu") or event.is_action_pressed("place_single_of_stack") \
		or event.is_action_pressed("place_half_of_stack") or event.is_action_pressed("quick_item_transfer") or event.is_action_pressed("drop_item"):
		equipment_slot_clicked.emit(slot_name, event)


func _on_mouse_entered() -> void:
	call_deferred("grab_focus")
	pass # Replace with function body.
