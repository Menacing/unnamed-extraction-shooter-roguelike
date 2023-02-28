extends GridContainer
class_name GridInventoryBase

var ito_items = []

var grid = {}
var cell_size = 32
var grid_width = 0
var grid_height = 0
var backpack_cell = preload("res://ui/inventory/backpack_cell.tscn")
var _max_height = 8

func _ready():
	Events.item_destroyed.connect(_on_item_destroyed)
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	for x in range(columns):
		grid[x] = {}
		for y in range(_max_height):
			grid[x][y] = null
			
func insert_item_at_first_available_spot(ito:InventoryTransferObject) -> bool:
	for y in range(grid_height):
		for x in range(grid_width):
			if try_insert_at_grid(x,y,ito):
#				ito.inv_item.global_position = global_position #+ Vector2(x, y) * cell_size
				ito.inv_item.position = Vector2(0,0)
				return true
	return false
	#TODO try rotating and repeating

func get_grid_size(item:Control) -> Dictionary:
	var results = {}
	var s = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results

func grab_item(pos) -> InventoryTransferObject:
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	var item_pos = get_item_pos(item)	
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item.inv_item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, null)
	
	ito_items.remove_at(ito_items.find(item))
	return item

func get_item_under_pos(pos) -> InventoryTransferObject:
	for item in ito_items:
		if item.inv_item.get_global_rect().has_point(pos):
			return item
	return null
	
func get_item_pos(ito:InventoryTransferObject) -> Vector2:
	var item_pos = ito.inv_item.global_position + Vector2(cell_size / 2, cell_size / 2)
	return item_pos
	
func pos_to_grid_coord(pos) -> Dictionary:
	var local_pos = pos - global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results

func set_grid_space(x, y, w, h, state:ItemComponent) -> void:
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state

func insert_item(ito:InventoryTransferObject) -> bool:
	var item_pos = get_item_pos(ito)
	var g_pos = pos_to_grid_coord(item_pos)
#	var item_size = get_grid_size(item)
	var item_size = get_item_comp_size(ito.item_component)
	if try_insert_at_grid(g_pos.x, g_pos.y, ito):
		ito
		return true
	else:
		return false
		
func get_item_comp_size(item_comp:ItemComponent) -> Dictionary:
	var results = {}
	results.x = item_comp.column_span
	results.y = item_comp.row_span
	return results
	
func try_insert_at_grid(x, y, ito:InventoryTransferObject) -> bool:
	var ic = ito.item_component
	var w = ic.column_span
	var h = ic.row_span
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	
	for i in range(x, x + w):
		for j in range(y, y + h):
			var grid_val = grid[i][j]
			if try_insert_stack(grid_val, ic):
				if ito.inv_item:
					ito.inv_item.queue_free()
				if ito.item_component:
					ito.item_component.destroy()
				Events.item_picked_up.emit(ito.item_component)				
				return true
			elif grid_val:
				return false
	set_grid_space(x, y, w, h, ic)
	var g_pos = {}
	g_pos.x = x
	g_pos.y = y
#	var norm_pos = get_relative_position(g_pos,ito)
#	ito.inv_item.global_position = norm_pos
	var cell = get_grid_cell_control(g_pos)
	ito.inv_item.reparent(cell)
	ito.inv_item.position = Vector2(0,0)
	ito_items.append(ito)
	Events.item_picked_up.emit(ito.item_component)
	return true

func try_insert_stack(existing_ic:ItemComponent, inserting_ic:ItemComponent) -> bool:
	if existing_ic and existing_ic.id == inserting_ic.id and inserting_ic.max_stack > 1 :
		existing_ic.stack += inserting_ic.stack
		if existing_ic.stack > inserting_ic.max_stack:
			inserting_ic.stack = existing_ic.stack - inserting_ic.max_stack
			existing_ic.stack = inserting_ic.max_stack
			return false
		else:
			return true
		return false
	else:
		return false
		
func get_grid_cell_control(g_pos:Dictionary) -> Control:
	var index = (g_pos.y)*columns + g_pos.x
	return self.get_child(index)
	
func drop_item(ito:InventoryTransferObject) -> void:
	ito.inv_item.queue_free()
	Events.item_dropped.emit(ito.item_component)
	pass

func _on_item_destroyed(item_comp:ItemComponent):
	for ito in ito_items:
		if item_comp == ito.item_component:
			var item_pos = get_item_pos(ito)	
			var g_pos = pos_to_grid_coord(item_pos)
			var item_size = get_grid_size(ito.inv_item)
			set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, null)
			ito_items.remove_at(ito_items.find(ito))
			ito.queue_free()
			return
