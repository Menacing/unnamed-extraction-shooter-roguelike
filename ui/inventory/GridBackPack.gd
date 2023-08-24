#extends GridInventoryBase
#class_name GridBackPack
#
#
#
#func _ready():
	#EventBus.item_equipped.connect(_on_backpack_added)
	#EventBus.item_removed.connect(_on_backpack_removed)
	#super()
#
##func get_relative_position(g_pos:Dictionary, ito:InventoryTransferObject) -> Vector2:
##	var r_pos = global_position + (Vector2(g_pos.x,g_pos.y) * cell_size)
##	return r_pos
#
#var _backpack_size:Backpack.Size = Backpack.Size.NONE
#var backpack_size:Backpack.Size: 
	#get:
		#return _backpack_size
	#set(size):
		#if size == Backpack.Size.NONE:
			#set_backpack_container_size(2*columns)
		#elif size == Backpack.Size.SMALL:
			#set_backpack_container_size(4*columns)	
		#elif size == Backpack.Size.MEDIUM:
			#set_backpack_container_size(6*columns)
		#elif size == Backpack.Size.LARGE:
			#set_backpack_container_size(8*columns)
		#_backpack_size = size
#
#func set_backpack_container_size(number_cells:int) -> void:
	##find number current cells
	#var current_cells:int = self.get_children().size()
	##figure out if we need to get larger or smaller
	##if larger, easy, just add more cells
	#if current_cells < number_cells:
		#while( self.get_children().size() < number_cells):
			#self.add_child(backpack_cell.instantiate())
	#elif current_cells > number_cells:
		##if smaller, drop items in cells to be dropped
		#var children = self.get_children()
		#while children.size() > number_cells :
			#var current_cell = children.pop_back()
			#var cell_global_pos = current_cell.get_global_position()
			#var item = grab_item(cell_global_pos)
			#if item:
				#drop_item(item)
		##then remove cells
			#self.remove_child(current_cell)
	#else:
		#pass
	#self.size.x = columns * cell_size
	#self.size.y = number_cells / columns * cell_size
	#var s = get_grid_size(self)
	#grid_width = s.x
	#grid_height = s.y
#
#
#
#func _on_backpack_added(slot_name, item_comp:ItemComponent):
	#if slot_name == "BackpackSlot":
		#backpack_size = item_comp.get_parent().backpack_size
#func _on_backpack_removed(slot_name, item_comp:ItemComponent):
	#if slot_name == "BackpackSlot":
		#backpack_size = Backpack.Size.NONE
#
#
