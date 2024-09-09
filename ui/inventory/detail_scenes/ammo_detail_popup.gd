extends ItemDetailPopup
class_name AmmoDetailPopup

@onready var item_name_label:Label = $VBoxContainer/TitleHBoxContainer/Label
@onready var item_model_anchor:Node3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/ItemModelAnchor
@onready var viewport_camera:Camera3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D
@onready var item_description_label:RichTextLabel = %DescriptionLabel
@onready var initial_speed_label:Label = $VBoxContainer/HBoxContainer/VBoxContainer/SpeedHBoxContainer/ValueLabel
@onready var initial_damage_label:Label = $VBoxContainer/HBoxContainer/VBoxContainer/DamageHBoxContainer/ValueLabel
@onready var penetration_rating_label:Label = $VBoxContainer/HBoxContainer/VBoxContainer/PenetrationHBoxContainer/ValueLabel

@export var item_outline_material:Material = load("res://ui/inventory/item_outline_material.tres")

var _weapon_modification_container:InventoryControlBase
var weapon_modification_container:InventoryControlBase:
	get:
		return $VBoxContainer/ModificationSlotVBoxContainer


var _item_3d:Item3D
var item_3d:Item3D:
	get:
		return _item_3d
	set(value):
		_item_3d = value
		map_item_name(value)
		map_item_description(value)
		map_ammo_values(value)
		setup_item_model(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_internal_inventory(internal_inventory:Inventory):
	weapon_modification_container._inventory = internal_inventory

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		#accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	self.queue_free()

func map_ammo_values(item_3d:Item3D):
	var item_inst:ItemInstance = item_3d.get_item_instance()
	var item_info = item_inst._item_info
	if item_info is AmmoInformation:
		var ammo_info:AmmoInformation = item_info
		
		initial_damage_label.text = str(ammo_info.ammo_subtype.initial_damage)
		initial_speed_label.text = str(ammo_info.ammo_subtype.initial_speed)
		penetration_rating_label.text = str(ammo_info.ammo_subtype.armor_penetration_rating)

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
