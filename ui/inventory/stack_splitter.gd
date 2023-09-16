extends PanelContainer
class_name StackSplitter

@onready var left_spin_box = $MarginContainer/VBoxContainer/HBoxContainer/LeftSpinBox
@onready var right_spin_box = $MarginContainer/VBoxContainer/HBoxContainer/RightSpinBox
@onready var hor_slider = $MarginContainer/VBoxContainer/HBoxContainer2/HSlider

var item_instance_id:int
var _max_stacks:int = 100
var max_stacks:int:
	get:
		return _max_stacks
	set(value):
		_max_stacks = value
		hor_slider.min_value = 1
		hor_slider.max_value = _max_stacks - 1
		hor_slider.value = _max_stacks / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	hor_slider.value_changed.connect(_on_h_slider_value_changed)
	left_spin_box.value_changed.connect(_on_left_spin_box_changed)
	right_spin_box.value_changed.connect(_on_right_spin_box_changed)
	var item_instance:ItemInstance = InventoryManager.get_item(item_instance_id)
	if item_instance:
		max_stacks = item_instance.stacks

func _on_h_slider_value_changed(value:float):
	right_spin_box.set_value_no_signal(value)
	left_spin_box.set_value_no_signal(max_stacks - value)
	
func _on_left_spin_box_changed(value:float):
	right_spin_box.set_value_no_signal(max_stacks - value)
	hor_slider.set_value_no_signal(max_stacks - value)
	
func _on_right_spin_box_changed(value:float):
	left_spin_box.set_value_no_signal(max_stacks - value)
	hor_slider.set_value_no_signal(value)
	

func _on_cancel_button_pressed():
	self.queue_free()


func _on_accept_button_pressed():
	#TODO Do the stack stuff
	var item_instance:ItemInstance = InventoryManager.get_item(item_instance_id)
	if item_instance:
		var destination = InventoryManager.find_clear_area_in_grid(item_instance_id, item_instance.current_inventory_id)
		if destination:
			InventoryManager.place_stack_in_grid(item_instance_id, item_instance.current_inventory_id, destination, right_spin_box.value)
	self.queue_free()
