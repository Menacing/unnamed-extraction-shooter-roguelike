extends Resource
class_name ModifiableStat

var _additive_modifiers = {}
var _multiplicitive_modifiers = {}

@export var base_value:float = 1.0

func _init(val:float):
	base_value = val

func get_modified_value() -> float:
	var value = base_value
	var factor = 1.0
	for amodk in _additive_modifiers:
		value += _additive_modifiers[amodk].value
	
	for mmodk in _multiplicitive_modifiers:
		factor += _multiplicitive_modifiers[mmodk].value
		
	value *= factor
	return value
	
func add_modifier(new_stat:StatModifier):
	if new_stat.operation == StatModifier.Operation.ADD:
		_additive_modifiers[new_stat.name] = new_stat
	elif new_stat.operation == StatModifier.Operation.MUL:
		_multiplicitive_modifiers[new_stat.name] = new_stat
	
func remove_modifier(stat:StatModifier):
	if stat.operation == StatModifier.Operation.ADD:
		_additive_modifiers.erase(stat.name)
	elif stat.operation == StatModifier.Operation.MUL:
		_multiplicitive_modifiers.erase(stat.name)
	
func remove_modifier_by_name(stat_name:String):
	_additive_modifiers.erase(stat_name)
	_multiplicitive_modifiers.erase(stat_name)
		
