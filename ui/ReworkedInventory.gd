extends Control

const item_base = preload("res://ui/inv_item_base.tscn")

@onready var inv_base:Panel = $InventoryBase
@onready var grid_bkpk:GridBackPack = $GridBackPack
@onready var eq_slots = $EquipmentSlots
@onready var cell_size:int = grid_bkpk.cell_size

var item_held:InventoryTransferObject = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()
var last_rotated: bool = false

func _ready():
	var gun:Gun = load("res://Scenes/Guns/AK47-Projectile/AK47-Projectile.tscn").instantiate()
	pickup_item(gun.get_node("ItemComponent"))

	var bp = load("res://Scenes/items/backpacks/large/large_backpack.tscn").instantiate()
	pickup_item(bp.get_node("ItemComponent"))
	
	pass
	

func _process(delta):
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
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
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
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
	

func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk, eq_slots, inv_base]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func drop_item():
	item_held.inv_item.queue_free()
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
	item.texture = item_comp.icon
	item.size.x = item_comp.column_span * cell_size
	item.size.y = item_comp.row_span * cell_size
	add_child(item)
	var ito = InventoryTransferObject.new()
	ito.inv_item = item
	ito.item_component = item_comp
	if !grid_bkpk.insert_item_at_first_available_spot(ito):
		item.queue_free()
		return false
	return true