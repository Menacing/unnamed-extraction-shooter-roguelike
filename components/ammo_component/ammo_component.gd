extends Node
class_name AmmoComponent

var _ammo_map:Dictionary = {}
var _active_ammo_type:AmmoType
var _active_ammo_subtype:AmmoSubtype

func _ready():
	var ammo_types = AmmoLoader.get_ammo_types()
	for at in ammo_types:
		_ammo_map[at.name] = {}
		for st in at.sub_types:
			var aci = AmmoCountInfo.new()
			aci.current_max = st.maximum_capacity
			_ammo_map[at.name][st.name] = aci
	EventBus.reserve_ammo_count_changed.emit(0)



##add ammo of a certain amount. Return the remainder over max
func add_ammo(ammo_type:AmmoType, ammo_subtype:AmmoSubtype, amount:int) -> int:
	var max = _ammo_map[ammo_type.name][ammo_subtype.name].current_max
	var current = _ammo_map[ammo_type.name][ammo_subtype.name].current_amount
	var new = current + amount
	if new <= max:
		_ammo_map[ammo_type.name][ammo_subtype.name].current_amount = new
		_signal_change(ammo_type, ammo_subtype, new)
		return 0
	else:
		_ammo_map[ammo_type.name][ammo_subtype.name].current_amount = max
		_signal_change(ammo_type, ammo_subtype, max)
		return new - max


##Ask for an amount of ammo. May not return the full amount if there isn't enough
func request_ammo(ammo_type:AmmoType, ammo_subtype:AmmoSubtype, amount:int) -> int:
	
	var current = _ammo_map[ammo_type.name][ammo_subtype.name].current_amount
	var new = current - amount
	if new < 0:
		_ammo_map[ammo_type.name][ammo_subtype.name].current_amount = 0
		_signal_change(ammo_type, ammo_subtype, 0)
		return current
	else:
		_ammo_map[ammo_type.name][ammo_subtype.name].current_amount = new
		_signal_change(ammo_type, ammo_subtype, new)
		return amount

func set_active_ammo(ammo_type:AmmoType, ammo_subtype:AmmoSubtype):
	_active_ammo_type = ammo_type
	_active_ammo_subtype = ammo_subtype
	_signal_change(ammo_type, ammo_subtype, _ammo_map[ammo_type.name][ammo_subtype.name].current_amount)
	
func _is_active_ammo(ammo_type:AmmoType, ammo_subtype:AmmoSubtype) -> bool:
	if _active_ammo_type and _active_ammo_type.name == ammo_type.name and _active_ammo_subtype and _active_ammo_subtype.name == ammo_subtype.name:
		return true
	else:
		return false
		
func _signal_change(ammo_type:AmmoType, ammo_subtype:AmmoSubtype, new_amount:int):
	if _is_active_ammo(ammo_type, ammo_subtype):
		EventBus.reserve_ammo_count_changed.emit(new_amount)

