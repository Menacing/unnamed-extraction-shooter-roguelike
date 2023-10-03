extends PanelContainer

@onready var mag_size_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/MagazineSizeHBoxContainer/ValueLabel
@onready var rpm_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/RPMHBoxContainer/ValueLabel
@onready var vertical_recoil_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/VerticalRecoilHBoxContainer/ValueLabel
@onready var horizontal_recoil_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/HorizontalHBoxContainer/ValueLabel
@onready var ads_speed_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/ADSSpeedHBoxContainer/ValueLabel
@onready var moa_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/MOAHBoxContainer/ValueLabel
@onready var turn_speed_label:Label = $VBoxContainer/HBoxContainer/StatsVBoxContainer/TurnSpeedHBoxContainer/ValueLabel
@onready var stats_box:Control = $VBoxContainer/HBoxContainer/StatsVBoxContainer
@onready var slots_box:Control = $VBoxContainer/ModificationSlotVBoxContainer

var item_instance_id:int

# Called when the node enters the scene tree for the first time.
func _ready():
	var item_instance:ItemInstance = instance_from_id(item_instance_id)
	if item_instance:
		pass


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
