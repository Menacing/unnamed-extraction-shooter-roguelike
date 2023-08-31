extends GridContainer
class_name InventoryGridContainer

@export var parent_inventory_control_base:InventoryControlBase
@export var grid_cell:PackedScene
var grid_width = 0
var grid_height = 0

var cell_size:int:
	get:
		return self.get_child(0).custom_minimum_size.x
		
func _ready():
	pass

func add_item_control(item_control:ItemControl, x:int, y:int):
	var cell = _get_grid_cell_control(x,y)
	assert(cell != null)
	Helpers.force_parent(item_control, cell)
	item_control.position = Vector2(0,0)
	
func _get_grid_size(item:Control) -> Dictionary:
	var results = {}
	var s = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results
	
func _get_grid_cell_control(x:int, y:int) -> Control:
	var index = (y)*columns + x
	return self.get_child(index)

func _get_grid_coordinates_from_global(g_pos:Vector2) -> Vector2i:
	var local_pos = g_pos - global_position
	var results = Vector2i()
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results

func _get_grid_coordinates_from_local(loc_pos:Vector2) -> Vector2i:
	var results = Vector2i()
	results.x = int(loc_pos.x / cell_size)
	results.y = int(loc_pos.y / cell_size)
	return results

func _get_droppable_container_under_cursor(pos:Vector2) -> Control:
	var containers = get_tree().get_nodes_in_group("droppable_inventory_controls")
	for c in containers:
		if c.get_global_rect().has_point(pos):
			return c
	return null

func _can_drop_data(at_position, data) -> bool:
	var item_instance_id:int = data["item_instance_id"]
	var number_to_drop:int = 0
	if data.has("number_to_drop"):
		number_to_drop = data["number_to_drop"]
	var target_inventory_id = parent_inventory_control_base._inventory.get_instance_id()

	var grid_pos = _get_grid_coordinates_from_local(at_position)
	#its a stack
	if number_to_drop > 0:
		return InventoryManager.can_place_stack_in_grid(item_instance_id,target_inventory_id, grid_pos, number_to_drop)
	#its not a stack
	else:
		return InventoryManager.can_place_item_in_grid(item_instance_id,target_inventory_id,grid_pos)

func _drop_data(at_position, data):
	print(data)	
	var item_instance_id:int = data["item_instance_id"]
	var number_to_drop:int = 0
	if data.has("number_to_drop"):
		number_to_drop = data["number_to_drop"]
	var target_inventory_id = parent_inventory_control_base._inventory.get_instance_id()

	var grid_pos = _get_grid_coordinates_from_local(at_position)
	#its a stack
	if number_to_drop > 0:
		if InventoryManager.can_place_stack_in_grid(item_instance_id,target_inventory_id, grid_pos, number_to_drop):
			InventoryManager.place_stack_in_grid(item_instance_id, target_inventory_id, grid_pos, number_to_drop)
	#its not a stack
	else:
		if InventoryManager.can_place_item_in_grid(item_instance_id,target_inventory_id,grid_pos):
			InventoryManager.place_item_in_grid(item_instance_id, target_inventory_id, grid_pos)
