extends Control
class_name InventoryControlBase

var item_held:ItemControl = null
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
			item_held.global_position = cursor_pos + item_offset
			#TODO Reimpliment Rotation
	#		if Input.is_action_just_pressed("rotate_held_item"):
	#			item_held.toggle_rotation(cell_size)
	#			item_offset = item_held.get_item_offset()

func get_container_with_method_under_cursor(cursor_pos:Vector2, method_name:String):
	var containers = get_tree().get_nodes_in_group("inventory_controls")
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			if c.has_method(method_name):
				return c
	return null

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
		
func drop_item():
	#TODO: Reimplement
#	if item_held.is_rotated():
#		item_held.toggle_rotation(cell_size)
#	item_held.inv_item.queue_free()
#	Events.item_dropped.emit(item_held.item_component)
#	item_held = null
	pass

func return_item():
	if item_held.is_rotated() != last_rotated:
		item_held.toggle_rotation()
	item_held.inv_item.global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null

func _on_context_menu_opened():
	listening_to_mouse = false

func _on_context_menu_closed():
	listening_to_mouse = true
