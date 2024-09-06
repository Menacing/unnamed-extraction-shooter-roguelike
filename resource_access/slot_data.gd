extends Resource
class_name SlotData

enum SLOT_DATA_TYPE {SLOT_DATA, GUN_SLOT_DATA}

@export var item_data:ItemInformation
@export_range(1,99) var quantity:int = 1: set = set_quantity
@export var durability:int = 1: set = set_durability
@export var root_index:int = 0
@export var is_rotated:bool = false
@export var internal_inventory:InventoryData = null

static func instantiate_from_item_information(item_information:ItemInformation) -> SlotData:
	var new_slot
	if item_information:
		match item_information.slot_data_type:
			SLOT_DATA_TYPE.GUN_SLOT_DATA:
				new_slot = GunSlotData.new()
			_:
				new_slot = SlotData.new()
		new_slot.item_data = item_information
		if item_information.has_stacks:
			#Default to fun!
			var stack:int = item_information.max_stacks
			if item_information.stack_random_method == GameplayEnums.StackRandomMethod.RANDOM:
				stack = randi_range(item_information.min_pickup_stacks, item_information.max_stacks)
			elif item_information.stack_random_method == GameplayEnums.StackRandomMethod.NORMAL:
				stack = Helpers.get_normalized_random_stack_count(item_information.min_pickup_stacks,
																  item_information.mean_pickup_stacks,
																  item_information.max_stacks)
			else:
				#Someone set an item up with a non specified random method, printing a missable
				#error and keeping the max default for more fun!
				printerr("{unhandled_enum_int} is an invalid integer for the GameplayEnums.StackRandomMethod enum. Defaulting to max stacks.".format({"unhandled_enum_int": item_information.stack_random_method}))

			new_slot.quantity = stack
		if item_information.has_durability:
			new_slot.durability = item_information.max_durability
		if item_information.model_internal_inventory:
			new_slot.internal_inventory = item_information.model_internal_inventory.duplicate(true)
	
	return new_slot

func can_merge_with(other_slot_data:SlotData, amount:int = 1) -> bool:
	return item_data == other_slot_data.item_data and item_data.has_stacks \
				and quantity + amount <= item_data.max_stacks

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
	
func create_half_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	
	new_slot_data.quantity = quantity/2
	quantity -= new_slot_data.quantity
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

func get_width() -> int:
	if item_data:
		if not is_rotated:
			return item_data.column_span
		else:
			return item_data.row_span
	else:
		return 1
	
func get_height() -> int:
	if item_data:
		if not is_rotated:
			return item_data.row_span
		else:
			return item_data.column_span
	else:
		return 1
