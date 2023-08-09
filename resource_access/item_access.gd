extends Object
class_name ItemAccess


func get_item(item_id:int) -> ItemInstance:
	var item = instance_from_id(item_id)
	if item is ItemInstance:
		return item
	else:
		return null
		
func combine_stacks(source:ItemInstance, destination:ItemInstance, amount:int) -> int:
	var remainder:int = 0
	if source:
		remainder = source.stacks
	
	if _can_combine_stacks(source, destination, amount):
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
	
static func _can_combine_stacks(source:ItemInstance, destination:ItemInstance, amount:int) -> bool:
		if source and destination and source.get_has_stacks() and destination.get_has_stacks() and \
		source.get_item_type_id() == destination.get_item_type_id():
			return true
		else:
			return false

func destroy_item(item:ItemInstance):
	if item:
		if item.id_3d:
			var item_3d:Node = instance_from_id(item.id_3d)
			item_3d.queue_free()
		if item.id_2d:
			var item_2d:Node = instance_from_id(item.id_2d)
			item_2d.queue_free()
		item.free()
