extends InventoryGridContainer
class_name WorldInventoryGrid

@export var container_size:int = 14

func _ready():
	set_container_size(container_size)
	super()
	
func set_container_size(number_cells:int) -> void:
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
			var cell_global_pos = current_cell.get_global_position()
			#var item = grab_item(cell_global_pos)
			#if item:
				#drop_item(item)
		#then remove cells
			self.remove_child(current_cell)
	else:
		pass
	self.size.x = columns * cell_size
	self.size.y = number_cells / columns * cell_size
	var s = _get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	


