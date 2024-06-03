extends GridContainer
class_name InventoryGridContainer

@export var parent_inventory_control_base:InventoryControlBase
@export var grid_cell:PackedScene
@export var disallow_equipped_backpacks:bool = false
@export var equipped_backpack_out_of_bounds:Vector2i = Vector2i(0,0)
@export var disabled_cells_overlay:Control

var cell_size:int:
	get:
		return self.get_child(0).custom_minimum_size.x
		
func _ready():
	pass

func _notification(what):
	if what == NOTIFICATION_DRAG_BEGIN and disabled_cells_overlay:
		var drag_data:Dictionary = get_viewport().gui_get_drag_data()
		if drag_data.has("is_equipped_backpack"):
			var is_equipped_backpack:bool = drag_data["is_equipped_backpack"]
			if is_equipped_backpack:
				disabled_cells_overlay.visible = true
	elif what == NOTIFICATION_DRAG_END and disabled_cells_overlay:
		disabled_cells_overlay.visible = false

func add_item_control(item_control:ItemControl, x:int, y:int):
	var cell:Control = _get_grid_cell_control(x,y)
	assert(cell != null)
	Helpers.force_parent(item_control, cell)
	item_control.position = Vector2(0,0)
	
func _get_grid_size(item:Control) -> Dictionary:
	var results = {}
	var s:Vector2 = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results
	
func _get_grid_cell_control(x:int, y:int) -> Control:
	var index:int = (y)*columns + x
	return self.get_child(index)

func _get_grid_coordinates_from_global(g_pos:Vector2) -> Vector2i:
	var local_pos:Vector2 = g_pos - global_position
	var results:Vector2i = Vector2i()
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
	for c:Control in containers:
		if c.get_global_rect().has_point(pos):
			return c
	return null

func _can_drop_data(at_position:Vector2, data) -> bool:
	var datad := data as Dictionary
	if datad:
		var item_instance_id:int = datad["item_instance_id"]
		var number_to_drop:int = 0
		var is_equipped_backpack = false
		if datad.has("number_to_drop"):
			number_to_drop = datad["number_to_drop"]
		if datad.has("is_equipped_backpack"):
			is_equipped_backpack = datad["is_equipped_backpack"]
		var target_inventory_id:int = parent_inventory_control_base._inventory.get_instance_id()

		var grid_pos:Vector2 = _get_grid_coordinates_from_local(at_position)
		#its a stack
		if number_to_drop > 0:
			return InventoryManager.can_place_stack_in_grid(item_instance_id,target_inventory_id, grid_pos, number_to_drop)
		#its not a stack
		else:
			#Don't allow players to drop equipped backpacks into their own inventory or we get weird behavior
			if is_equipped_backpack and disallow_equipped_backpacks:
				
				var boundary_test_result = InventoryManager.item_at_position_goes_beyond_point(item_instance_id, grid_pos, equipped_backpack_out_of_bounds)
				if boundary_test_result:
					return false
			return InventoryManager.can_place_item_in_grid(item_instance_id,target_inventory_id,grid_pos)
	else:
		return false

func _drop_data(at_position:Vector2, data):
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

	
func set_grid_container_size(number_cells:int) -> void:
	assert(number_cells > 0)
	#find number current cells
	var current_cells:int = self.get_children().size()
	#figure out if we need to get larger or smaller
	#if larger, easy, just add more cells
	if current_cells < number_cells:
		while( self.get_children().size() < number_cells):
			self.add_child(grid_cell.instantiate())
	elif current_cells > number_cells:
		#if smaller, drop items in cells to be dropped
		var children = self.get_children()
		while children.size() > number_cells :
			var current_cell = children.pop_back()
			#then remove cells
			self.remove_child(current_cell)
	else:
		pass
	self.size.x = columns * cell_size
	@warning_ignore("integer_division")
	self.size.y = number_cells / columns * cell_size
	
