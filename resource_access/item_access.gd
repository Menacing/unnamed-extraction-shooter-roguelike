extends Object
class_name ItemAccess


static func get_item(item_id:int) -> ItemInstance:
	var item = instance_from_id(item_id)
	if item is ItemInstance:
		return item
	else:
		return null
		
static func combine_stacks(source:ItemInstance, destination:ItemInstance, amount:int) -> int:
	var remainder:int = 0
	if source:
		remainder = source.stacks
	
	if can_combine_stacks(source, destination):
		#if source stack has enough, do the amount
		if amount <= source.stacks:
			destination.stacks += amount
			source.stacks -= amount
		#else give what you have
		else:
			destination.stacks += source.stacks
			source.stacks = 0
		if destination.stacks > destination.get_max_allowed_stacks():
			source.stacks += destination.stacks - destination.get_max_allowed_stacks()
			destination.stacks = destination.get_max_allowed_stacks()
		remainder = source.stacks
	
	return remainder
	
static func can_combine_stacks(source:ItemInstance, destination:ItemInstance) -> bool:
		if source and destination and source.get_has_stacks() and destination.get_has_stacks() and \
		source.get_item_type_id() == destination.get_item_type_id() and destination.stacks < destination.get_max_allowed_stacks():
			return true
		else:
			return false

static func destroy_item(item:ItemInstance):
	if item:
		if item.id_3d:
			var item_3d:Node = instance_from_id(item.id_3d)
			item_3d.queue_free()
		if item.id_2d:
			var item_2d:Node = instance_from_id(item.id_2d)
			item_2d.queue_free()
		item.free()

static func clone_instance(original: ItemInstance) -> ItemInstance:
	var new_instance = ItemInstance.new()

	# Copy properties
	if original.id_3d != 0:
		new_instance.id_3d = Helpers.duplicate_node_by_id(original.id_3d).get_instance_id()
	if original.id_2d != 0:
		new_instance.id_2d = Helpers.duplicate_node_by_id(original.id_2d).get_instance_id()

	# If ItemInformation class also needs to be deep-copied, you'd have to make 
	# a similar function for that and replace the line below.
	new_instance._item_info = original._item_info  

	new_instance.stacks = original.stacks
	new_instance.durability = original.durability
	new_instance.current_inventory_id = original.current_inventory_id
	new_instance.is_rotated = original.is_rotated

	return new_instance
