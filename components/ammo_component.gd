extends Node
class_name AmmoComponent

var _ammo_map:Dictionary
var _active_ammo_type:GameplayEnums.AmmoType
var _active_ammo_subtype:int

func _init():
	_ammo_map = GameplayEnums.get_ammo_map()

#add ammo of a certain amount. Return the remainder over max
func add_ammo(ammo_type:GameplayEnums.AmmoType, ammo_subtype:int, amount:int) -> int:
	var max = _ammo_map[ammo_type][ammo_subtype]["max"]
	var current = _ammo_map[ammo_type][ammo_subtype]["current"]
	var new = current + amount
	if new <= max:
		_ammo_map[ammo_type][ammo_subtype]["current"] = new
		_signal_change(ammo_type, ammo_subtype, new)
		return 0
	else:
		_ammo_map[ammo_type][ammo_subtype]["current"] = max
		_signal_change(ammo_type, ammo_subtype, max)
		return new - max

#Ask for an amount of ammo. May not return the full amount if there isn't enough
func request_ammo(ammo_type:GameplayEnums.AmmoType, ammo_subtype:int, amount:int) -> int:
	
	var current = _ammo_map[ammo_type][ammo_subtype]["current"]
	var new = current - amount
	if new < 0:
		_ammo_map[ammo_type][ammo_subtype]["current"] = 0
		_signal_change(ammo_type, ammo_subtype, 0)
		return current
	else:
		_ammo_map[ammo_type][ammo_subtype]["current"] = new
		_signal_change(ammo_type, ammo_subtype, new)
		return amount

func set_active_ammo(ammo_type:GameplayEnums.AmmoType, ammo_subtype:int):
	_active_ammo_type = ammo_type
	_active_ammo_subtype = ammo_subtype
	
func _is_active_ammo(ammo_type:GameplayEnums.AmmoType, ammo_subtype:int) -> bool:
	if _active_ammo_type == ammo_type and _active_ammo_subtype == ammo_subtype:
		return true
	else:
		return false
		
func _signal_change(ammo_type:GameplayEnums.AmmoType, ammo_subtype:int, new_amount:int):
	if _is_active_ammo(ammo_type, ammo_subtype):
		EventBus.reserve_ammo_count_changed.emit(new_amount)
