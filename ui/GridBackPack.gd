extends GridContainer
class_name GridBackPack

var ito_items = []

var grid = {}
var cell_size = 32
var grid_width = 0
var grid_height = 0

func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false

func insert_item(ito:InventoryTransferObject) -> bool:
	var item_pos = get_item_pos(ito)
	var g_pos = pos_to_grid_coord(item_pos)
#	var item_size = get_grid_size(item)
	var item_size = get_item_comp_size(ito.item_component)
	
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
			
		var norm_pos = get_relative_position(g_pos,ito)
		ito.inv_item.global_position = norm_pos
		ito_items.append(ito)
		return true
	else:
		return false

func grab_item(pos) -> InventoryTransferObject:
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	var item_pos = get_item_pos(item)	
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item.inv_item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	
	ito_items.remove_at(ito_items.find(item))
	return item
	
func get_item_pos(ito:InventoryTransferObject) -> Vector2:
	var item_pos = ito.inv_item.global_position + Vector2(cell_size / 2, cell_size / 2)
	return item_pos

func pos_to_grid_coord(pos) -> Dictionary:
	var local_pos = pos - global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results

func get_grid_size(item:Control) -> Dictionary:
	var results = {}
	var s = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results

func get_item_comp_size(item_comp:ItemComponent) -> Dictionary:
	var results = {}
	results.x = item_comp.column_span
	results.y = item_comp.row_span
	return results

func is_grid_space_available(x, y, w ,h) -> bool:
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true

func set_grid_space(x, y, w, h, state) -> void:
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state

func get_item_under_pos(pos) -> InventoryTransferObject:
	for item in ito_items:
		if item.inv_item.get_global_rect().has_point(pos):
			return item
	return null

func insert_item_at_first_available_spot(ito:InventoryTransferObject) -> bool:
	for y in range(grid_height):
		for x in range(grid_width):
			if !grid[x][y]:
				ito.inv_item.global_position = global_position + Vector2(x, y) * cell_size
				if insert_item(ito):
					return true
	return false

func get_relative_position(g_pos:Dictionary, ito:InventoryTransferObject) -> Vector2:
	var r_pos = global_position + (Vector2(g_pos.x,g_pos.y) * cell_size)
	return r_pos
	
