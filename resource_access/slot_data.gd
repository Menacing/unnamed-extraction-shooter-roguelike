extends Resource
class_name SlotData

@export var item_data:ItemInformation
@export_range(1,99) var quantity:int = 1: set = set_quantity
@export var durability:int = 1: set = set_durability
@export var root_index:int = 0

func can_merge_with(other_slot_data:SlotData) -> bool:
	return item_data == other_slot_data.item_data and item_data.has_stacks \
				and quantity < item_data.max_stacks

func can_fully_merge_with(other_slot_data:SlotData) -> bool:
	return item_data == other_slot_data.item_data and item_data.has_stacks \
				and quantity + other_slot_data.quantity <= item_data.max_stacks

func fully_merge_with(other_slot_data:SlotData) -> void:
	quantity += other_slot_data.quantity

func create_single_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func set_quantity(value:int) -> void:
	quantity = value
	if quantity > 1 and not item_data.has_stacks:
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item_data.display_name)
		
func set_durability(value:int) -> void:
	durability = value
	if not item_data.has_durability:
		durability = 1
		push_error("%s does not have durability, setting durability to 1" % item_data.display_name)
