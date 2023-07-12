extends Control
class_name BaseInventory

const item_base = preload("res://ui/inventory/inv_item_base.tscn")
const backpack_cell = preload("res://ui/inventory/backpack_cell.tscn")

@export var grid_inv_path:NodePath
@onready var grid_inv:GridInventoryBase = get_node(grid_inv_path)
@export var eq_slots_path:NodePath
@onready var eq_slots = get_node(eq_slots_path)
@onready var cell_size:int = grid_inv.cell_size

var item_held:InventoryTransferObject = null
var item_offset = Vector2()
var last_z
var last_container = null
var last_pos = Vector2()
var last_rotated: bool = false
var listening_to_mouse:bool = true


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
			last_z = item_held.inv_item.z_index
			item_held.inv_item.z_index = 1000
			move_child(item_held.inv_item, get_child_count())
			
func release(cursor_pos):
	if item_held == null:
		return
	if last_z:
		item_held.inv_item.z_index = last_z
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
	item.name_label.text = item_comp.inventory_info.display_name
	item.show_name = item_comp.inventory_info.show_name
	item.item_texture_rect.texture = item_comp.inventory_info.icon
	item.size.x = item_comp.inventory_info.column_span * cell_size
	item.size.y = item_comp.inventory_info.row_span * cell_size
	item.tooltip_text = item_comp.inventory_info.tooltip_text
	item.z_index = 50
	
	if item_comp.inventory_info.max_stacks > 1:
		item.show_count = true
		item.stacks = item_comp.stack
	else: item.show_count = false
	
	if item_comp.inventory_info.max_durability > 1:
		item.show_durability = true
		item.durability = item_comp.durability
		item.max_durability = item_comp.inventory_info.max_durability
	else: item.show_durability = false
	item.context_items = item_comp.inventory_info.context_menu_items
	
	add_child(item)
	var ito = InventoryTransferObject.new()
	ito.inv_item = item
	ito.item_component = item_comp
	ito.cell_width = item_comp.inventory_info.column_span
	ito.cell_height = item_comp.inventory_info.row_span
	item_comp.stack_changed.connect(ito.inv_item._on_count_changed)
	item_comp.durability_changed.connect(ito.inv_item._on_durability_changed)
	#TODO First check item slots
	var item_slot = item_comp.inventory_info.item_type
	if eq_slots:
		for slot in eq_slots.slots:
			if item_slot in slot.types and eq_slots.items[slot.name] == null:
	#			ito.inv_item.global_position = slot.global_position + slot.size / 2 - ito.inv_item.size / 2
				return eq_slots.insert_item_in_slot(ito, slot)
	if !grid_inv.insert_item_at_first_available_spot(ito):
		item.queue_free()
		return false
	return true
	
func _on_context_menu_dropped(iib:ItemControl, pos:Vector2):
	grab(pos)
	drop_item()
	
func _on_context_menu_opened():
	listening_to_mouse = false

func _on_context_menu_closed():
	listening_to_mouse = true

func _on_open_detail_popup(iib:ItemControl, pos:Vector2):
	var popup = load("res://ui/inventory/item_detail_popup.tscn").instantiate()
	add_child(popup)
	popup.popup_centered()
	pass
