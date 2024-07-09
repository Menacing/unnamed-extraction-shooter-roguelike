extends Node

var _item_info_mapping:Dictionary = {}
var resource_group:ResourceGroup = load("res://game_objects/items/item_information_resource_group.tres")

var item_instances:Dictionary = {}
var item_3ds:Dictionary = {}
var item_controls:Dictionary = {}

func _init():
	# declare a type safe array
	var item_infos:Array[ItemInformation] = []
	# fills the array with the resources from the resource group
	resource_group.load_all_into(item_infos)
	map_item_info_array(item_infos)
	if _item_info_mapping.size() == 0:
		push_error("NO ITEM INFORMATION FOUND")

func map_item_info_array(iia:Array[ItemInformation]):
	for info:ItemInformation in iia:
		_item_info_mapping[info.item_type_id] = info
	
func spawn_from_item3d(item3d:Item3D):
	if item3d:
		var item_info:ItemInformation = _item_info_mapping[item3d.item_type_id]
		if item_info == null:
			push_error("No ItemInformation found for item_type_id %" % item3d.item_type_id)
		var item_instance:ItemInstance = ItemInstance.new(item_info)
		item3d.item_instance_id = item_instance.item_instance_id
		item_instance.id_3d = item3d.item_3d_id
		item_instance.spawn_item()
		
func spawn_from_item_type_id(item_type_id:String) -> ItemInstance:
	var item_info:ItemInformation = _item_info_mapping[item_type_id]
	if item_info == null:
		push_error("No ItemInformation found for item_type_id %" % item_type_id)
	var item_instance:ItemInstance = ItemInstance.new(item_info)
	item_instance.item_instance_id = Helpers.generate_new_id()
	item_instance.spawn_item()
	return item_instance

func get_item_information(item_type_id:String) -> ItemInformation:
	var item_info:ItemInformation = _item_info_mapping[item_type_id]
	return item_info

func add_item_instance(inst:ItemInstance) -> bool:
	if item_instances.has(inst.item_instance_id):
		print("item instance already exists")
		return false
	elif inst.item_instance_id == 0:
		print("item instance does not have id set")
		return false
	item_instances[inst.item_instance_id] = inst
	return true

func get_item_instance(item_instance_id:int) -> ItemInstance:
	if item_instances[item_instance_id] is ItemInstance:
		return item_instances[item_instance_id]
	else:
		return null

func add_item_3d(item3d:Item3D) -> bool:
	if item_3ds.has(item3d.item_3d_id):
		print("item3d already exists")
		return false
	elif item3d.item_3d_id == 0:
		print("item3d does not have id set")
		return false
	item_3ds[item3d.item_3d_id] = item3d
	return true
	
func get_item_3d(item_3d_id:int) -> Item3D:
	if item_3ds[item_3d_id] is Item3D:
		return item_3ds[item_3d_id]
	else:
		return null

func add_item_control(item_control:ItemControl) -> bool:
	if item_controls.has(item_control.item_control_id):
		print("item control already exists")
		return false
	elif item_control.item_control_id == 0:
		print("item control does not have id set")
		return false
	item_controls[item_control.item_control_id] = item_control
	return true
	
func get_item_control(item_control_id:int) -> ItemControl:
	if item_controls[item_control_id] is ItemControl:
		return item_controls[item_control_id]
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

func destroy_item(item:ItemInstance) -> void:
	if item:
		if item.id_3d:
			var item_3d:Item3D = item_3ds[item.id_3d]
			item_3ds.erase(item.id_3d)
			item_3d.queue_free()
		if item.id_2d:
			var item_2d:ItemControl = item_controls[item.id_2d]
			item_controls.erase(item.id_2d)
			item_2d.queue_free()
		item_instances.erase(item.item_instance_id)
		item.free()

func clone_instance(original: ItemInstance) -> ItemInstance:
	var new_instance := ItemInstance.new(original._item_info)

	# Copy properties
	if original.id_3d != 0:
		var dupe_3d:Item3D = Helpers.duplicate_node_by_id(original.id_3d)
		dupe_3d.item_3d_id = Helpers.generate_new_id()
		dupe_3d.item_instance_id = new_instance.item_instance_id
		new_instance.id_3d = dupe_3d.item_3d_id
		
	if original.id_2d != 0:
		var new_item_control:ItemControl = Helpers.duplicate_node_by_id(original.id_2d)
		new_item_control.item_instance_id = new_instance.item_instance_id
		new_item_control.item_control_id = Helpers.generate_new_id()
		new_instance.id_2d = new_item_control.item_control_id

	# If ItemInformation class also needs to be deep-copied, you'd have to make 
	# a similar function for that and replace the line below.
	new_instance._item_info = original._item_info  

	new_instance.stacks = original.stacks
	new_instance.durability = original.durability
	new_instance.current_inventory_id = original.current_inventory_id
	new_instance.is_rotated = original.is_rotated

	return new_instance
