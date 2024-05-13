extends ItemDetailPopup
class_name GunDetailPopup

@onready var item_name_label:Label = $VBoxContainer/TitleHBoxContainer/Label
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

var _weapon_modification_container:InventoryControlBase
var weapon_modification_container:InventoryControlBase:
	get:
		return $VBoxContainer/ModificationSlotVBoxContainer


var weapon_mod_template_scene = preload("res://ui/inventory/weapon_modification_slot.tscn")

var _gun_3d:Gun
var gun_3d:Gun:
	get:
		return _gun_3d
	set(value):
		_gun_3d = value
		map_item_name(value)
		map_gun_stats(value)
		map_gun_description(value)
		setup_gun_model(value)
		setup_mod_slots(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	var item_instance:ItemInstance = instance_from_id(item_instance_id)
	if item_instance:
		var item_3d = instance_from_id(item_instance.id_3d)
		if item_3d and item_3d is Gun:
			gun_3d = item_3d
		
		

func set_internal_inventory(internal_inventory:Inventory):
	weapon_modification_container._inventory = internal_inventory

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	self.queue_free()

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
	var item_inst = gun.get_item_instance()
	var constructed_description_string:String = ""
	constructed_description_string += item_inst.get_item_description_text().to_upper()
	constructed_description_string += "\n\n"
	constructed_description_string += "[i]"
	constructed_description_string += item_inst.get_item_flavor_text().to_upper()
	constructed_description_string += "[/i]"
	item_description_label.text = constructed_description_string

func map_item_name(gun:Gun):
	item_name_label.text = gun.get_item_instance().get_display_name()
	
func setup_gun_model(gun:Gun):
	Helpers.force_parent(gun.copy_gun_model(), item_model_anchor)
	adjust_camera_to_fit()
	
func setup_mod_slots(gun:Gun):
	#get the internal inventory
	var item_inventory:Inventory = gun.get_item_instance().get_item_inventory()

	#get the equipment slots
	var item_equipment_slots:Array[EquipmentSlotType] = item_inventory.equipment_slots
	var current_sibling:Node = $VBoxContainer/ModificationSlotVBoxContainer/FrontSpacer
	for slot in item_equipment_slots:
		#for each equipment slot, create a weapon mod slot instance
		var slot_control:EquipmentSlotControl = weapon_mod_template_scene.instantiate()
		#set the name and icon based on the slot info
		slot_control.name = slot.name
		slot_control.slot_icon = _get_slot_icon(slot.allowed_types)
		#Set up connection to inventory control, probably the vbox container
		slot_control.parent_inventory_control_base = weapon_modification_container
		#add it as child to vbox container
		current_sibling.add_sibling(slot_control)
		slot_control.owner = self
		current_sibling = slot_control
		
		#if the slot has an item, put the item control in the slot
		if slot.item_instance_id != 0:
			var item_instance:ItemInstance = instance_from_id(slot.item_instance_id)
			if item_instance:
				var item_control:ItemControl = item_instance.get_item_control()
				if item_control:
					slot_control.add_item_control(item_control)
		pass
	pass

func adjust_camera_to_fit():
	# Ensure item_model_anchor has content.
	if item_model_anchor.get_child_count() == 0:
		return

	# Calculate the AABB (Axis-Aligned Bounding Box) of the entire model container.
	var aabb:AABB = Helpers.get_aabb_of_node(item_model_anchor)
	var largest_axis:float = aabb.get_longest_axis_size()
	viewport_camera.size = largest_axis * 1.1
	
var armor_icon = preload("res://themes/ArmorSlotIcon-1.png.png")
var backpack_icon = preload("res://themes/BackpackSlotIcon-1.png.png")
var foregrip_icon = preload("res://themes/Foregrip Icon-1.png.png")
var grip_icon = preload("res://themes/Grip Icon-1.png.png")
var gun_icon = preload("res://themes/GunSlotIcon-1.png.png")
var laser_icon = preload("res://themes/Laser Icon-1.png.png")
var mag_icon = preload("res://themes/Magazine Icon-1.png.png")
var muzzle_icon = preload("res://themes/Muzzle Icon-1.png.png")
var scope_icon = preload("res://themes/Scope Icon-1.png.png")
var stock_icon = preload("res://themes/Stock Icon-1.png.png")
var oops_icon = preload("res://themes/LegIcon.png")

func _get_slot_icon(item_types:Array[GameplayEnums.ItemType]) -> Texture2D:
	match (item_types[0]):
		GameplayEnums.ItemType.GUN:
			return gun_icon
		GameplayEnums.ItemType.ARMOR:
			return armor_icon
		GameplayEnums.ItemType.BACKPACK:
			return backpack_icon
		GameplayEnums.ItemType.FOREGRIP:
			return foregrip_icon
		GameplayEnums.ItemType.GRIP:
			return grip_icon
		GameplayEnums.ItemType.LASER:
			return laser_icon
		GameplayEnums.ItemType.MAG:
			return mag_icon
		GameplayEnums.ItemType.MUZZLE:
			return muzzle_icon
		GameplayEnums.ItemType.OPTIC:
			return scope_icon
		GameplayEnums.ItemType.STOCK:
			return stock_icon
		_:
			return oops_icon
	
	
