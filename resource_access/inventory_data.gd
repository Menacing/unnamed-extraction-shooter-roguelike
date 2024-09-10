extends Resource
class_name InventoryData

signal inventory_updated(inventory_data:InventoryData)
signal inventory_interact(inventory_data:InventoryData, index:int, event:InputEvent)
signal inventory_equipment_slot_interact(inventory_data:InventoryData, slot_name:String, event:InputEvent)
signal inventory_context_menu(inventory_data:InventoryData, slot_data:SlotData)
signal inventory_equipment_slot_context_menu(inventory_data:InventoryData, equipment_slot:EquipmentSlot)
signal inventory_drop_item(slot_data:SlotData)
signal item_equipment_changed(inventory_data:InventoryData, equipment_slot:EquipmentSlot)
signal item_show_detail_scene(slot_data:SlotData, detail_scene:ItemDetailPopup)
signal ammo_picked_up(inventory_data:InventoryData, slot_data:SlotData)

var width = 10
@export var equipment_slots:Array[EquipmentSlot]
@export var slot_datas:Array[Array]


func set_inventory_size(new_number_rows:int) -> void:
	var current_height:int = slot_datas.size()
	
	if new_number_rows == current_height:
		return 
	elif new_number_rows > current_height:
		for i in range(0,new_number_rows - current_height):
			var new_row = []
			new_row.resize(width)
			slot_datas.append(new_row)
	elif new_number_rows < current_height:
		
		for i in range(current_height - 1, new_number_rows, -1):
			#drop each item in row
			for j in width:
				var slot_data:SlotData = slot_datas[i][j]
				if slot_data:
					slot_data = grab_slot_data(slot_data.root_index)
					inventory_drop_item.emit(slot_data)
			#remove row
			slot_datas.pop_back()
		
	inventory_updated.emit(self)
	
	pass

func _get_equipment_slot(slot_name:String) -> EquipmentSlot:
	var equipment_slot:EquipmentSlot

	for es:EquipmentSlot in equipment_slots:
		if es.slot_name == slot_name:
			equipment_slot = es
			break
	return equipment_slot

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

func grab_equipment_slot_data(slot_name:String) -> SlotData:
	var slot_data:SlotData
	if slot_name:
		var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)
		
		if equipment_slot:
			slot_data = equipment_slot.slot_data
			if slot_data:
				equipment_slot.slot_data = null
				inventory_updated.emit(self)
				item_equipment_changed.emit(self, equipment_slot)
	
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

func drop_equipment_slot_data(grabbed_slot_data:SlotData, slot_name:String) -> SlotData:
	var return_slot_data:SlotData
	var original_slot_data:SlotData
	var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)

	if equipment_slot:
		original_slot_data = equipment_slot.slot_data

			
	#If empty, check if allowed
	if not original_slot_data:
		if grabbed_slot_data.item_data.item_type in equipment_slot.allowed_types:
			equipment_slot.slot_data = grabbed_slot_data
			item_equipment_changed.emit(self, equipment_slot)
			return_slot_data = null
		else:
			#not allowed, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_fully_merge_with(grabbed_slot_data):
			original_slot_data.fully_merge_with(grabbed_slot_data)
		#else check for space for swap
		else:
			if grabbed_slot_data.item_data.item_type in equipment_slot.allowed_types:
				equipment_slot.slot_data = grabbed_slot_data
				item_equipment_changed.emit(self, equipment_slot)
				
				return_slot_data = original_slot_data
			else:
				#not allowed, do nothing, don't need to update inventory
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
		if original_slot_data.can_merge_with(grabbed_slot_data, grabbed_slot_data.quantity/2):
			original_slot_data.fully_merge_with(grabbed_slot_data.create_half_slot_data())
	
	inventory_updated.emit(self)

	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null
		
func drop_half_slot_data_equipment_slot(grabbed_slot_data:SlotData, slot_name:String) -> SlotData:
	var return_slot_data:SlotData
	var original_slot_data:SlotData
	var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)

	if equipment_slot:
		original_slot_data = equipment_slot.slot_data
	
	#If empty, check if allowed
	if not original_slot_data:
		if grabbed_slot_data.item_data.item_type in equipment_slot.allowed_types:
			equipment_slot.slot_data = grabbed_slot_data.create_half_slot_data()
			item_equipment_changed.emit(self, equipment_slot)
			return_slot_data = null
		else:
			#not allowed, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_merge_with(grabbed_slot_data, grabbed_slot_data.quantity/2):
			original_slot_data.fully_merge_with(grabbed_slot_data.create_half_slot_data())
		
	inventory_updated.emit(self)
	
	return return_slot_data

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
		
func drop_single_slot_data_equipment_slot(grabbed_slot_data:SlotData, slot_name:String) -> SlotData:
	var return_slot_data:SlotData
	var original_slot_data:SlotData
	var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)

	if equipment_slot:
		original_slot_data = equipment_slot.slot_data
	
	#If empty, check if allowed
	if not original_slot_data:
		if grabbed_slot_data.item_data.item_type in equipment_slot.allowed_types:
			equipment_slot.slot_data = grabbed_slot_data.create_single_slot_data()
			item_equipment_changed.emit(self, equipment_slot)
			return_slot_data = null
		else:
			#not allowed, do nothing, don't need to update inventory
			return grabbed_slot_data
	#else check if can merge
	else:
		if original_slot_data.can_merge_with(grabbed_slot_data):
			original_slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
		
	inventory_updated.emit(self)
	
	return return_slot_data

func open_slot_context_menu(index:int) -> void:
	var row_i = index/width
	var col_i = index % width
	var slot_data = slot_datas[row_i][col_i]
	
	if not slot_data:
		return
	else:
		inventory_context_menu.emit(self, slot_data)

func open_equipment_slot_context_menu(slot_name:String) -> void:
	var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)
	var slot_data:SlotData
	if equipment_slot:
		slot_data = equipment_slot.slot_data
	
	if not slot_data:
		return
	else:
		inventory_equipment_slot_context_menu.emit(self, equipment_slot)

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
			"Item Detail":
				var detail_scene:PackedScene = slot_data.item_data.detail_scene
				var detail_control:ItemDetailPopup = detail_scene.instantiate()
				item_show_detail_scene.emit(slot_data, detail_control)
				pass
	pass

func handle_equipment_slot_context_menu(menu_id:int, slot_name:String) -> void:
	var equipment_slot:EquipmentSlot = _get_equipment_slot(slot_name)
	
	var slot_data:SlotData = equipment_slot.slot_data
	if slot_data:
		var item:ItemContextItem = slot_data.item_data.context_menu_items[menu_id]
		
		match item.label:
			"Drop":
				grab_equipment_slot_data(slot_name)
				inventory_drop_item.emit(slot_data)
				inventory_updated.emit(self)
			"Item Detail":
				var detail_scene:PackedScene = slot_data.item_data.detail_scene
				var detail_control:ItemDetailPopup = detail_scene.instantiate()
				item_show_detail_scene.emit(slot_data, detail_control)
				pass
	pass

##Checks for space to pick up an item into the inventory data. Returns true if successful
func pick_up_slot_data(slot_data:SlotData) -> bool:
	#check for suitable equipment slot
	for equipment_slot:EquipmentSlot in equipment_slots:
		if !equipment_slot.slot_data and slot_data.item_data.item_type in equipment_slot.allowed_types:
			equipment_slot.slot_data = slot_data
			inventory_updated.emit(self)
			item_equipment_changed.emit(self, equipment_slot)
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
	
func on_equipment_slot_clicked(slot_name:String, event:InputEvent) -> void:
	inventory_equipment_slot_interact.emit(self, slot_name, event)

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
			
	if slot_data and slot_data.item_data.item_type == GameplayEnums.ItemType.AMMO:
		ammo_picked_up.emit(self, slot_data)

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

func deep_duplicate() -> InventoryData:
	var new_inventory_data = InventoryData.new()
	var new_equipment_slots:Array[EquipmentSlot] = []
	for i: int in equipment_slots.size():
		var val = equipment_slots[i]
		if val and val is Resource:
			new_equipment_slots.append(val.duplicate(true))
		else:
			new_equipment_slots.append(val)
	new_inventory_data.equipment_slots = new_equipment_slots
	
	var new_slot_datas:Array[Array] = []
	for i in slot_datas.size():
		var new_row = []
		new_row.resize(width)
		new_slot_datas.append(new_row)
		for j in width:
			new_slot_datas[i][j] = slot_datas[i][j]
			
	new_inventory_data.slot_datas = new_slot_datas
	return new_inventory_data
