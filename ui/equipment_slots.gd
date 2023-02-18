extends Panel
class_name EquipmentSlots

@onready var slots = get_children()
@export var cell_size = 32
var items = {}

func _ready() -> void:
	for slot in slots:
		items[slot.name] = null

func insert_item(item:InventoryTransferObject) -> bool:
	if item.is_rotated():
		item.toggle_rotation(cell_size)
	var item_pos = item.inv_item.global_position + item.inv_item.size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	
	var item_slot = item.item_component.type
	if item_slot not in slot.types:
		return false
	if items[slot.name] != null:
		return false
	items[slot.name] = item

	item.inv_item.global_position = slot.global_position + slot.size / 2 - item.inv_item.size / 2
	Events.item_equipped.emit(slot.name, item.item_component)
	return true

func grab_item(pos):
	var item:InventoryTransferObject = get_item_under_pos(pos)
	var slot = get_slot_under_pos(pos)
	if item == null:
		return null
	
	items[slot.name] = null
	Events.item_removed.emit(slot.name, item.item_component)
	return item

func get_slot_under_pos(pos):
	var arr = slots
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null

func get_item_under_pos(pos) -> InventoryTransferObject:
	var arr = items.values()
	for thing in arr:
		if thing != null and thing.inv_item.get_global_rect().has_point(pos):
			return thing
	return null

