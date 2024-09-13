extends ItemDetailPopup
class_name BackpackDetailPopup

@onready var item_name_label:Label = $VBoxContainer/TitleHBoxContainer/Label
@onready var item_model_anchor:Node3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/ItemModelAnchor
@onready var viewport_camera:Camera3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D
@onready var item_description_label:RichTextLabel = %DescriptionLabel
@onready var backpack_size_label:Label = $VBoxContainer/HBoxContainer/BackpackSizeHBoxContainer/ValueLabel

@export var item_outline_material:Material = load("res://ui/inventory/item_outline_material.tres")

var _item_3d:Item3D
var item_3d:Item3D:
	get:
		return _item_3d
	set(value):
		_item_3d = value
		map_item_name(value)
		map_item_description(value)
		map_backpack_size(value)
		setup_item_model(value)

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		#accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	self.queue_free()

func map_backpack_size(backpack:Backpack):
	if backpack:
		if backpack.backpack_size == Backpack.Size.NONE:
			backpack_size_label.text = "+ 0"
		elif backpack.backpack_size == Backpack.Size.SMALL:
			backpack_size_label.text = "+ 14"
		elif backpack.backpack_size == Backpack.Size.MEDIUM:
			backpack_size_label.text = "+ 28"
		elif backpack.backpack_size == Backpack.Size.LARGE:
			backpack_size_label.text = "+ 42"

func map_item_description(item:Item3D):
	var item_inst = item.get_item_instance()
	var constructed_description_string:String = ""
	constructed_description_string += item_inst.get_item_description_text().to_upper()
	constructed_description_string += "\n\n"
	constructed_description_string += "[i]"
	constructed_description_string += item_inst.get_item_flavor_text().to_upper()
	constructed_description_string += "[/i]"
	item_description_label.text = constructed_description_string

func map_item_name(item:Item3D):
	item_name_label.text = item.get_item_instance().get_display_name()
	#title = item.get_item_instance().get_display_name()
	
func setup_item_model(item:Item3D):
	#clear any existing children
	for child in item_model_anchor.get_children():
		child.queue_free()
		
	var model = item.copy_model()
	
	Helpers.apply_material_overlay_to_children(model, item_outline_material)
	Helpers.force_parent(model, item_model_anchor)
	
	adjust_camera_to_fit()
	

func adjust_camera_to_fit():
	# Ensure item_model_anchor has content.
	if item_model_anchor.get_child_count() == 0:
		return

	var largest_axis = item_3d.longest_side_size
	viewport_camera.size = largest_axis * 1.1
