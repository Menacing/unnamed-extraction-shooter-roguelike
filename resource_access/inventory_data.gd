extends Resource
class_name InventoryData

signal inventory_updated(inventory_data:InventoryData)
signal inventory_interact(inventory_data:InventoryData, index:int, event:InputEvent)
signal inventory_context_menu(slot_data:SlotData)

var width = 7
@export var equipment_slots:Array[EquipmentSlotType]
@export var slot_datas:Array[Array]

func grab_slot_data(index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	
	var slot_data = slot_datas[row_i][col_i]
	
	if slot_data:
		slot_datas[row_i][col_i] = null
		inventory_updated.emit(self)
		
	return slot_data
	
func drop_slot_data(grabbed_slot_data:SlotData, index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	var slot_data = slot_datas[row_i][col_i]
	
	var return_slot_data:SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[row_i][col_i] = grabbed_slot_data
		return_slot_data = slot_data
		
	inventory_updated.emit(self)
	
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data:SlotData, index:int) -> SlotData:
	var row_i = index/width
	var col_i = index % width
	var slot_data = slot_datas[row_i][col_i]
	
	if not slot_data:
		slot_datas[row_i][col_i] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
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
		inventory_context_menu.emit(slot_data)
	
	print(slot_data.item_data.display_name)

#TODO Rework this for item width and height
func pick_up_slot_data(slot_data:SlotData) -> bool:
	#check for mergable slot first
	for row_i in slot_datas.size():
		for col_i in slot_datas[row_i].size():
			if slot_datas[row_i][col_i] and slot_datas[row_i][col_i].can_fully_merge_with(slot_data):
				slot_datas[row_i][col_i].fully_merge_with(slot_data)
				inventory_updated.emit(self)
				return true
	
	for row_i in slot_datas.size():
		for col_i in slot_datas[row_i].size():
			if not slot_datas[row_i][col_i]:
				set_slot_data(row_i, col_i, slot_data)
				inventory_updated.emit(self)
				return true
	
	return false

func on_slot_clicked(index:int, event:InputEvent) -> void:
	inventory_interact.emit(self, index, event)

func set_slot_data_by_index(index:int, slot_data:SlotData) -> void:
	var row_i = index/width
	var col_i = index % width
	
	set_slot_data(row_i, col_i, slot_data)

func set_slot_data(row_i:int, col_i:int, slot_data:SlotData) -> void:
	
	var item_width = slot_data.item_data.column_span
	var item_height = slot_data.item_data.row_span
	 
	for i in range(row_i, row_i + item_height):
		for j in range(col_i, col_i + item_width):
			slot_datas[i][j] = slot_data
