extends Object
class_name ItemAccess


func get_item(item_id:int) -> ItemInstance:
	var item = instance_from_id(item_id)
	if item is ItemInstance:
		return item
	else:
		return null
		
func combine_stacks(source_item:ItemInstance, destination_item:ItemInstance) -> ItemCombineStackResult:
	var result = ItemCombineStackResult.new()
	if source_item.get_item_type_id() != destination_item.get_item_type_id():
		return result
	elif destination_item.stacks == destination_item.get_max_allowed_stacks():
		return result
	elif destination_item.get_max_allowed_stacks() > 1:
		destination_item.stacks += source_item.stacks
		source_item.stacks = 0
		if destination_item.stacks > destination_item.get_max_allowed_stacks():
			source_item.stacks = destination_item.stacks - destination_item.get_max_allowed_stacks()
			destination_item.stacks = destination_item.get_max_allowed_stacks()
			result.result = ItemCombineStackResult.ResultTypes.PARTIALLY_COMBINED
			return result
		else:
			result.result = ItemCombineStackResult.ResultTypes.FULLY_COMBINED
			return result
	else:
		return result

func partially_combine_stacks(source_item:ItemInstance, destination_item:ItemInstance, number:int) -> ItemCombineStackResult:
	var result = ItemCombineStackResult.new()
	#can't combine different item types
	if source_item.get_item_type_id() != destination_item.get_item_type_id():
		return result
	#can't combine if destination is full
	elif destination_item.stacks == destination_item.get_max_allowed_stacks():
		return result
	#can't combine if source doesn't have enough 
	elif source_item.stacks < number:
		return result
	elif destination_item.get_max_allowed_stacks() > 1:
		destination_item.stacks += number
		source_item.stacks -= number
		if destination_item.stacks > destination_item.get_max_allowed_stacks():
			source_item.stacks += destination_item.stacks - destination_item.get_max_allowed_stacks()
			destination_item.stacks = destination_item.get_max_allowed_stacks()
			result.result = ItemCombineStackResult.ResultTypes.PARTIALLY_COMBINED
			return result
		else:
			result.result = ItemCombineStackResult.ResultTypes.FULLY_COMBINED
			return result
	else:
		return result

func destroy_item(item:ItemInstance):
	if item:
		if item.id_3d:
			var item_3d:Node = instance_from_id(item.id_3d)
			item_3d.queue_free()
		if item.id_2d:
			var item_2d:Node = instance_from_id(item.id_2d)
			item_2d.queue_free()
		item.free()
