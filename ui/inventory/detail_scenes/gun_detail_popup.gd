extends ItemDetailPopup
class_name GunDetailPopup

@onready var mag_size_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/MagazineSizeHBoxContainer/ValueLabel
@onready var rpm_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/RPMHBoxContainer/ValueLabel
@onready var vertical_recoil_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/VerticalRecoilHBoxContainer/ValueLabel
@onready var horizontal_recoil_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/HorizontalHBoxContainer/ValueLabel
@onready var ads_speed_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/ADSSpeedHBoxContainer/ValueLabel
@onready var moa_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/MOAHBoxContainer/ValueLabel
@onready var turn_speed_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/TurnSpeedHBoxContainer/ValueLabel
@onready var stats_box:Control = $VBoxContainer/HBoxContainer/StatsVBoxContainer
@onready var slots_box:Control = $VBoxContainer/ModificationSlotVBoxContainer
@onready var item_model_anchor:Node3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/ItemModelAnchor
@onready var viewport_camera:Camera3D = $VBoxContainer/HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D
@onready var item_description_label:RichTextLabel = %DescriptionLabel
@onready var weapon_name_label:Label = $VBoxContainer/TitleHBoxContainer/WeaponNameLabel
@onready var weapon_category_label:Label = $VBoxContainer/TitleHBoxContainer/WeaponCategoryLabel
@onready var ammo_type_label:Label = $VBoxContainer/TitleHBoxContainer/AmmoTypeLabel


@export var item_outline_material:Material = load("res://ui/inventory/item_outline_material.tres")

const EQUIPMENT_SLOT = preload("res://ui/inventory/3.0/equipment_slot.tscn")

func set_slot_data(slot_data:SlotData) -> void:
	if slot_data is GunSlotData:
		var item_3d:Item3D = Item3D.instantiate_from_slot_data(slot_data)
		if item_3d is Gun:
			#add as child to trigger onready
			item_model_anchor.add_child(item_3d)
			gun_3d = item_3d
	else:
		printerr("Tried setting generic slot data for gun popup")
	pass

var _gun_3d:Gun
var gun_3d:Gun:
	get:
		return _gun_3d
	set(value):
		_gun_3d = value
		map_item_name(value)
		map_gun_stats(value)
		map_gun_description(value)
		map_weapon_category(value)
		map_ammo_type(value)
		setup_gun_model(value)
		setup_mod_slots(value)



func map_gun_stats(gun:Gun):
	var gun_stats:GunStats = gun.get_gun_stats()
	mag_size_label.text = str(gun.get_max_magazine_size())
	rpm_label.text = str(gun_stats.rpm)
	vertical_recoil_label.text = str(round(gun_stats.base_recoil.y*1000)) + "±" + str(round(gun_stats.recoil_variability.y*1000))
	horizontal_recoil_label.text = str(round(gun_stats.base_recoil.x*1000)) + "±" + str(round(gun_stats.recoil_variability.x*1000))
	ads_speed_label.text = str(gun_stats.ads_accel)
	moa_label.text = str(gun_stats.moa)
	turn_speed_label.text = str(gun_stats.turn_speed)

func map_gun_description(gun:Gun):
	var item_information:ItemInformation = gun.slot_data.item_data
	var constructed_description_string:String = ""
	constructed_description_string += item_information.description_text.to_upper()
	constructed_description_string += "\n\n"
	constructed_description_string += "[i]"
	constructed_description_string += item_information.flavor_text.to_upper()
	constructed_description_string += "[/i]"
	item_description_label.text = constructed_description_string

func map_item_name(gun:Gun):
	weapon_name_label.text = gun.slot_data.item_data.display_name
	#title = gun.slot_data.item_data.display_name
	
func map_weapon_category(gun:Gun):
	weapon_category_label.text = gun.get_weapon_category()
	
func map_ammo_type(gun:Gun):
	ammo_type_label.text = gun.get_ammo_type().name

func setup_gun_model(gun:Gun):
	#clear any existing children
	for child in item_model_anchor.get_children():
		child.queue_free()
		
	var model = gun.copy_model()
	model.rotate_y(deg_to_rad(90))
	Helpers.apply_material_overlay_to_children(model, item_outline_material)
	Helpers.force_parent(model, item_model_anchor)
	
	adjust_camera_to_fit()
	
func setup_mod_slots(gun:Gun):
	var gun_slot_data:GunSlotData = gun.slot_data
	#get the internal inventory
	var item_inventory:InventoryData = gun_slot_data.internal_inventory
	

	if item_inventory:
		if parent_inventory_interface:
			parent_inventory_interface._connect_inventory_data_signals(item_inventory)
			_inventory_data = item_inventory
		item_inventory.inventory_updated.connect(update_mod_slots)
		update_mod_slots(item_inventory)

func update_mod_slots(item_inventory:InventoryData) -> void :
		#get the equipment slots
	var item_equipment_slots:Array[EquipmentSlot] = item_inventory.equipment_slots
	var current_sibling:Node = $VBoxContainer/ModificationSlotVBoxContainer/FrontSpacer
	#clear out existing slots
	for child in slots_box.get_children():
		if !child.is_in_group("spacer"):
			slots_box.remove_child(child)
			child.queue_free()
	for slot in item_equipment_slots:
		
		#for each equipment slot, create a weapon mod slot instance
		var slot_control = EQUIPMENT_SLOT.instantiate()
		slot_control.name = slot.slot_name
		#add it as child to vbox container
		current_sibling.add_sibling(slot_control)
		
		slot_control.equipment_slot_clicked.connect(item_inventory.on_equipment_slot_clicked)

		slot_control.set_slot_data(slot)
		slot_control.owner = self
		current_sibling = slot_control

func adjust_camera_to_fit():
	# Ensure item_model_anchor has content.
	if item_model_anchor.get_child_count() == 0:
		return

	var largest_axis = gun_3d.longest_side_size
	viewport_camera.size = largest_axis * 1.1
