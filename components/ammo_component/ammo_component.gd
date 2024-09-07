extends Node
class_name AmmoComponent

var _ammo_map:Dictionary = {}
var _active_ammo_type:String
var _active_ammo_subtype:String
var _actor_id:int
@export var drop_location:Node3D

func _ready():
	var ammo_map_size = _ammo_map.keys().size()
	if  ammo_map_size == 0:
		var ammo_types = AmmoLoader.get_ammo_types()
		for at in ammo_types:
			_ammo_map[at.name] = {}
			for st in at.sub_types:
				var aci = AmmoCountInfo.new()
				aci.current_max = st.maximum_capacity
				aci.subtype_item_id = st.item_type_id
				_ammo_map[at.name][st.name] = aci
		EventBus.active_reserve_ammo_count_changed.emit(0)
	else:
		EventBus.active_reserve_ammo_count_changed.emit(_ammo_map[_active_ammo_type][_active_ammo_subtype].current_amount)
		
	_actor_id = get_parent().get_instance_id()
	EventBus.drop_ammo.connect(_on_drop_ammo)
	EventBus.drop_all_ammo.connect(_on_drop_all_ammo)

##get the current amount of an ammo subtype
func get_ammo_subtype_count(ammo_type:String, ammo_subtype:String) -> int:
	return _ammo_map[ammo_type][ammo_subtype].current_amount

##add ammo of a certain amount. Return the remainder over max
func add_ammo(ammo_type:String, ammo_subtype:String, amount:int) -> int:
	var max = _ammo_map[ammo_type][ammo_subtype].current_max
	var current = _ammo_map[ammo_type][ammo_subtype].current_amount
	var new = current + amount
	if new <= max:
		_ammo_map[ammo_type][ammo_subtype].current_amount = new
		_signal_change(ammo_type, ammo_subtype, new)
		return 0
	else:
		_ammo_map[ammo_type][ammo_subtype].current_amount = max
		_signal_change(ammo_type, ammo_subtype, max)
		return new - max

func _on_drop_ammo(actor_id:int, type:String, subtype:String, amount:int):
	if actor_id == _actor_id and drop_location:
		var ammo_amount = request_ammo(type, subtype, amount)
		var aci:AmmoCountInfo = _ammo_map[type][subtype]
		var item_information:ItemInformation = ItemMappingRepository.get_item_information(aci.subtype_item_id)
		var max_stacks = item_information.max_stacks
		
		while ammo_amount > 0:
			var slot_data:SlotData = SlotData.new()
			slot_data.item_data = item_information
			if ammo_amount > max_stacks:
				slot_data.quantity = max_stacks
				ammo_amount -= max_stacks
			else:
				slot_data.quantity = ammo_amount
				ammo_amount = 0
			
			var item_3d:Item3D = Item3D.instantiate_from_slot_data(slot_data)
			Helpers.force_parent(item_3d,get_parent().get_parent())
			item_3d.dropped()
			item_3d.global_position = drop_location.global_position
	pass
	
func _on_drop_all_ammo(actor_id:int, type:String, subtype:String):
	if actor_id == _actor_id and drop_location:
		var all_ammo_amount = _ammo_map[type][subtype].current_amount
		_on_drop_ammo(actor_id, type, subtype, all_ammo_amount)

##Ask for an amount of ammo. May not return the full amount if there isn't enough
func request_ammo(ammo_type:String, ammo_subtype:String, amount:int) -> int:
	
	var current = _ammo_map[ammo_type][ammo_subtype].current_amount
	var new = current - amount
	if new < 0:
		_ammo_map[ammo_type][ammo_subtype].current_amount = 0
		_signal_change(ammo_type, ammo_subtype, 0)
		return current
	else:
		_ammo_map[ammo_type][ammo_subtype].current_amount = new
		_signal_change(ammo_type, ammo_subtype, new)
		return amount

func request_all_ammo(ammo_type:String, ammo_subtype:String) -> int:
	var current = _ammo_map[ammo_type][ammo_subtype].current_amount

	_ammo_map[ammo_type][ammo_subtype].current_amount = 0
	_signal_change(ammo_type, ammo_subtype, 0)
	return current

		
func set_active_ammo(ammo_type:String, ammo_subtype:String):
	_active_ammo_type = ammo_type
	_active_ammo_subtype = ammo_subtype
	_signal_change(ammo_type, ammo_subtype, _ammo_map[ammo_type][ammo_subtype].current_amount)
	
func _is_active_ammo(ammo_type:String, ammo_subtype:String) -> bool:
	if _active_ammo_type and _active_ammo_type == ammo_type and _active_ammo_subtype and _active_ammo_subtype == ammo_subtype:
		return true
	else:
		return false
		
func _signal_change(ammo_type:String, ammo_subtype:String, new_amount:int):
	if _is_active_ammo(ammo_type, ammo_subtype):
		EventBus.active_reserve_ammo_count_changed.emit(new_amount)
	EventBus.reserve_ammo_count_changed.emit(ammo_type, ammo_subtype, new_amount)
