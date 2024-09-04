extends Resource
class_name InventoryData

signal inventory_updated(inventory_data:InventoryData)
signal inventory_interact(inventory_data:InventoryData, index:int, event:InputEvent)
signal inventory_context_menu(inventory_data:InventoryData, slot_data:SlotData)
signal inventory_drop_item(slot_data:SlotData)
signal item_equipped(equipment_slot:EquipmentSlot)
signal item_unequipped(equipment_slot:EquipmentSlot)

var width = 7
@export var equipment_slots:Array[EquipmentSlot]
@export var slot_datas:Array[Array]

##Pickup slot data OUT OF inventory
func grab_slot_data(index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	
	var slot_data:SlotData = slot_datas[row_i][col_i]
	
	if slot_data:
		row_i = slot_data.root_index / width
		col_i = slot_data.root_index % width
		set_slot_data(row_i, slot_data.get_height(), col_i, slot_data.get_width(), null)
		inventory_updated.emit(self)
		
	return slot_data

##Drop slot data INTO inventory
func drop_slot_data(grabbed_slot_data:SlotData, index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	var original_slot_data:SlotData = slot_datas[row_i][col_i]
	
	var return_slot_data:SlotData
	#If empty, check for space
	if not original_slot_data:
		if room_for_slot_data(index, grabbed_slot_data):
			set_slot_data(row_i, grabbed_slot_data.get_height(), col_i, grabbed_slot_data.get_width(), grabbed_slot_data)
			return_slot_data = null
		else:
			#no room, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_fully_merge_with(grabbed_slot_data):
			original_slot_data.fully_merge_with(grabbed_slot_data)
		#else check for space for swap
		else:
			#remove original
			set_slot_data_by_index(original_slot_data.root_index, null, original_slot_data.get_height(), original_slot_data.get_width())
			
			
			if room_for_slot_data(index, grabbed_slot_data):
				set_slot_data(row_i, grabbed_slot_data.get_height(), col_i, grabbed_slot_data.get_width(), grabbed_slot_data)
				return_slot_data = original_slot_data
			else:
				set_slot_data_by_index(original_slot_data.root_index, original_slot_data)
				#no room, do nothing, don't need to update inventory
				return grabbed_slot_data
		
	inventory_updated.emit(self)
	
	return return_slot_data

func drop_half_slot_data(grabbed_slot_data:SlotData, index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	var original_slot_data = slot_datas[row_i][col_i]
	
	#If empty, check for space
	if not original_slot_data:
		if room_for_slot_data(index, grabbed_slot_data):
			set_slot_data(row_i, grabbed_slot_data.get_height(), col_i, grabbed_slot_data.get_width(), grabbed_slot_data.create_half_slot_data())
		else:
			#no room, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_merge_with(grabbed_slot_data):
			original_slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)

	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func drop_single_slot_data(grabbed_slot_data:SlotData, index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	var original_slot_data = slot_datas[row_i][col_i]
	
	#If empty, check for space
	if not original_slot_data:
		if room_for_slot_data(index, grabbed_slot_data):
			set_slot_data(row_i, grabbed_slot_data.get_height(), col_i, grabbed_slot_data.get_width(), grabbed_slot_data.create_single_slot_data())
		else:
			#no room, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_merge_with(grabbed_slot_data):
			original_slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)

	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

#TODO finish this
func open_slot_context_menu(index:int) -> void:
	var row_i = index/width
	var col_i = index % width
	var slot_data = slot_datas[row_i][col_i]
	
	if not slot_data:
		return
	else:
		inventory_context_menu.emit(self, slot_data)
	
	print(slot_data.item_data.display_name)
	
func handle_context_menu(menu_id:int, slot_index:int) -> void:
	var row_i = slot_index/width
	var col_i = slot_index % width
	
	var slot_data:SlotData = slot_datas[row_i][col_i]
	if slot_data:
		var item:ItemContextItem = slot_data.item_data.context_menu_items[menu_id]
		
		match item.label:
			"Drop":
				grab_slot_data(slot_index)
				inventory_drop_item.emit(slot_data)
				inventory_updated.emit(self)
		
	pass
	

func pick_up_slot_data(slot_data:SlotData) -> bool:
	#check for suitable equipment slot
	for equipment_slot:EquipmentSlot in equipment_slots:
		if !equipment_slot.slot_data and slot_data.item_data.item_type in equipment_slot.allowed_types:
			equipment_slot.slot_data = slot_data
			item_equipped.emit(equipment_slot)
			inventory_updated.emit(self)
			return true
	
	
	#check for mergable slot first
	for row_i in slot_datas.size():
		for col_i in slot_datas[row_i].size():
			if slot_datas[row_i][col_i] and slot_datas[row_i][col_i].can_fully_merge_with(slot_data):
				slot_datas[row_i][col_i].fully_merge_with(slot_data)
				inventory_updated.emit(self)
				return true
	var test_index:int = 0
	for row_i in slot_datas.size():
		for col_i in slot_datas[row_i].size():
			if room_for_slot_data(test_index,slot_data):
				set_slot_data(row_i, slot_data.get_height(), col_i, slot_data.get_width(), slot_data)
				inventory_updated.emit(self)
				return true
			test_index += 1
	return false

func on_slot_clicked(index:int, event:InputEvent) -> void:
	inventory_interact.emit(self, index, event)

func set_slot_data_by_index(index:int, slot_data:SlotData, h:int = 1, w:int = 1) -> void:
	var row_i = index/width
	var col_i = index % width
	
	if slot_data:
		h = slot_data.get_height()
		w = slot_data.get_width()
	
	set_slot_data(row_i, h, col_i, w, slot_data)

func set_slot_data(row_i:int, item_height:int, col_i:int, item_width:int, slot_data:SlotData) -> void:
	if slot_data:
		slot_data.root_index = (row_i * width) + col_i
	for i in range(row_i, row_i + item_height):
		for j in range(col_i, col_i + item_width):
			slot_datas[i][j] = slot_data

func room_for_slot_data(target_index:int, slot_data:SlotData) -> bool:
	var row_i = target_index/width
	var col_i = target_index % width
	var h: = 0
	var w: = 0
	
	if slot_data:
		h = slot_data.get_height()
		w = slot_data.get_width()
	
	#check for out of bounds
	if row_i + h > slot_datas.size():
		return false
	if col_i + w > width:
		return false
	
	for i in range(row_i, row_i + h):
		for j in range(col_i, col_i + w):
			#check for existing data
			if slot_datas[i][j]:
				return false
	
	return true
