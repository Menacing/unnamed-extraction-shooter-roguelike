extends Object
class_name ItemAccess

var _item_info_mapping:Dictionary = {}
var _path = "res://game_objects/items/"

func _init():
	load_item_info_from_path(_item_info_mapping, _path)
	if _item_info_mapping.size() == 0:
		push_error("NO ITEM INFORMATION FOUND")

	
static func load_item_info_from_path(item_info_dictionary:Dictionary, path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				load_item_info_from_path(item_info_dictionary, path + "/" + file_name)
			else:
				if file_name.ends_with(".tres"):
					var res = load(path + "/" + file_name) 
					if res is ItemInformation:
						print("Adding ItemInfo: " + file_name)
						if !res.item_type_id:
							push_error(file_name + " does not have item_type_id set!")
						if item_info_dictionary.has(res.item_type_id):
							push_error("item_type_id collision on " + res.item_type_id + " in " + file_name)
						else:
							item_info_dictionary[res.item_type_id] = res
			file_name = dir.get_next()
	
func spawn_from_item3d(item3d:Item3D):
	if item3d:
		var item_info:ItemInformation = _item_info_mapping[item3d.item_type_id]
		if item_info == null:
			push_error("No ItemInformation found for item_type_id %" % item3d.item_type_id)
		var item_instance:ItemInstance = ItemInstance.new(item_info)
		item3d.item_instance_id = item_instance.get_instance_id()
		item_instance.id_3d = item3d.get_instance_id()
		item_instance.spawn_item()
		
func spawn_from_item_type_id(item_type_id) -> ItemInstance:
	var item_info:ItemInformation = _item_info_mapping[item_type_id]
	if item_info == null:
		push_error("No ItemInformation found for item_type_id %" % item_type_id)
	var item_instance:ItemInstance = ItemInstance.new(item_info)
	item_instance.spawn_item()
	return item_instance

static func get_item(item_id:int) -> ItemInstance:
	var item:Object = instance_from_id(item_id)
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

static func destroy_item(item:ItemInstance) -> void:
	if item:
		if item.id_3d:
			var item_3d:Node = instance_from_id(item.id_3d)
			item_3d.queue_free()
		if item.id_2d:
			var item_2d:Node = instance_from_id(item.id_2d)
			item_2d.queue_free()
		item.free()

static func clone_instance(original: ItemInstance) -> ItemInstance:
	var new_instance := ItemInstance.new(original._item_info)

	# Copy properties
	if original.id_3d != 0:
		new_instance.id_3d = Helpers.duplicate_node_by_id(original.id_3d).get_instance_id()
		#TODO: Tie the 3d representation to the item instance
	if original.id_2d != 0:
		var new_item_control:ItemControl = Helpers.duplicate_node_by_id(original.id_2d)
		new_item_control.item_instance_id = new_instance.get_instance_id()
		new_instance.id_2d = new_item_control.get_instance_id()

	# If ItemInformation class also needs to be deep-copied, you'd have to make 
	# a similar function for that and replace the line below.
	new_instance._item_info = original._item_info  

	new_instance.stacks = original.stacks
	new_instance.durability = original.durability
	new_instance.current_inventory_id = original.current_inventory_id
	new_instance.is_rotated = original.is_rotated

	return new_instance
