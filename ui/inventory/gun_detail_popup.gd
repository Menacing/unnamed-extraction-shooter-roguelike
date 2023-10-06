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


var _gun_3d:Gun
var gun_3d:Gun:
	get:
		return _gun_3d
	set(value):
		_gun_3d = value
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
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	self.queue_free()

func map_gun_stats(gun:Gun):
	pass

func map_gun_description(gun:Gun):
	pass
	
func setup_gun_model(gun:Gun):
	Helpers.force_parent(gun.copy_gun_model(), item_model_anchor)
	adjust_camera_to_fit()
	
func setup_mod_slots(gun:Gun):
	pass

func adjust_camera_to_fit():
	# Ensure item_model_anchor has content.
	if item_model_anchor.get_child_count() == 0:
		return

	# Calculate the AABB (Axis-Aligned Bounding Box) of the entire model container.
	var aabb:AABB = Helpers.get_aabb_of_node(item_model_anchor)
	var largest_axis:float = aabb.get_longest_axis_size()
	viewport_camera.size = largest_axis * 1.1
