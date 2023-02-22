extends Control

const item_base = preload("res://ui/inv_item_base.tscn")

@onready var inv_base:Control = %InventoryBase
@onready var grid_bkpk:GridBackPack = %GridBackPack
@onready var eq_slots = %EquipmentSlots
@onready var cell_size:int = grid_bkpk.cell_size

var item_held:InventoryTransferObject = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()
var last_rotated: bool = false
var listening_to_mouse:bool = true


func _ready():
	Events.context_menu_dropped.connect(_on_context_menu_dropped)
	Events.context_menu_closed.connect(_on_context_menu_closed)
	Events.context_menu_opened.connect(_on_context_menu_opened)
	pass
	

func _process(delta):
	if listening_to_mouse:
		var cursor_pos = get_global_mouse_position()
		if Input.is_action_just_pressed("inv_grab"):
			grab(cursor_pos)
		if Input.is_action_just_released("inv_grab"):
			release(cursor_pos)
		if item_held != null:
			item_held.inv_item.global_position = cursor_pos + item_offset
			if Input.is_action_just_pressed("rotate_held_item"):
				item_held.toggle_rotation(cell_size)
				item_offset = item_held.get_item_offset()

func grab(cursor_pos):
	var c = get_container_with_method_under_cursor(cursor_pos,"grab_item")
	if c != null:
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = item_held.inv_item.global_position
			item_offset = item_held.get_item_offset()
			last_rotated = item_held.is_rotated()
			move_child(item_held.inv_item, get_child_count())

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_with_method_under_cursor(cursor_pos,"insert_item")
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
	

func get_container_with_method_under_cursor(cursor_pos:Vector2, method_name:String):
	var containers = get_tree().get_nodes_in_group("inventory_controls")
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			if c.has_method(method_name):
				return c
	return null

func drop_item():
	if item_held.is_rotated():
		item_held.toggle_rotation(cell_size)
	item_held.inv_item.queue_free()
	Events.item_dropped.emit(item_held.item_component)
	item_held = null

func return_item():
	if item_held.is_rotated() != last_rotated:
		item_held.toggle_rotation(cell_size)
	item_held.inv_item.global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null

func pickup_item(item_comp:ItemComponent):
	var item = item_base.instantiate()
	item.set_meta("id", item_comp.node_id)
	item.item_texture_rect.texture = item_comp.icon
	item.size.x = item_comp.column_span * cell_size
	item.size.y = item_comp.row_span * cell_size
	item.tooltip_text = item_comp.tooltip_text
	item.z_index = 50
	
	if item_comp.max_stack > 1:
		item.show_count = true
		item.stacks = item_comp.stack
	else: item.show_count = false
	
	add_child(item)
	var ito = InventoryTransferObject.new()
	ito.inv_item = item
	ito.item_component = item_comp
	item_comp.stack_changed.connect(ito.inv_item._on_count_changed)
	#TODO First check item slots
	var item_slot = item_comp.type
	for slot in eq_slots.slots:
		if item_slot in slot.types and eq_slots.items[slot.name] == null:
#			ito.inv_item.global_position = slot.global_position + slot.size / 2 - ito.inv_item.size / 2
			return eq_slots.insert_item_in_slot(ito, slot)
	if !grid_bkpk.insert_item_at_first_available_spot(ito):
		item.queue_free()
		return false
	return true
	
func _on_context_menu_dropped(iib:InvItemBase, pos:Vector2):
	grab(pos)
	drop_item()
	
func _on_context_menu_opened():
	listening_to_mouse = false

func _on_context_menu_closed():
	listening_to_mouse = true
