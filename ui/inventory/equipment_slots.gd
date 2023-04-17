extends Control
class_name EquipmentSlots

@onready var slots = get_children()
@export var cell_size = 32
var items = {}

func _ready() -> void:
	Events.item_destroyed.connect(_on_item_destroyed)
	for slot in slots:
		items[slot.name] = null

func insert_item(item:InventoryTransferObject) -> bool:
	var item_pos = item.inv_item.global_position + item.inv_item.size / 2
	var slot = get_slot_under_pos(item_pos)
	return insert_item_in_slot(item, slot)

func insert_item_in_slot(item:InventoryTransferObject, slot) -> bool:
	if slot == null:
		return false
	if item.is_rotated():
		item.toggle_rotation(cell_size)
	
	var item_slot = item.item_component.inventory_info.item_type
	if item_slot not in slot.types:
		return false
	if items[slot.name] != null:
		return false
	items[slot.name] = item

	item.inv_item.global_position = slot.global_position + slot.size / 2 - item.inv_item.size / 2
	item.inv_item.reparent(slot)
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
	
func _on_item_destroyed(item_comp:ItemComponent):
	for ito_key in items:
		var ito = items[ito_key]
		if ito and item_comp == ito.item_component:
			items[ito_key] = null
			ito.inv_item.queue_free()
			return

