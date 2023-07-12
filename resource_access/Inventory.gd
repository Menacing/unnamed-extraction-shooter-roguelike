@tool
extends Resource
class_name Inventory

@export var initial_height:int:
	get:
		return initial_height
	set(value):
		_current_height = value
		initial_height = value
var _current_height:int

@export var initial_width:int:
	get:
		return initial_width
	set(value):
		_current_width = value
		initial_width = value
var _current_width:int

var grid_slots = {}
@export var equipment_slots:Array[EquipmentSlot] = []

func setup():
	_current_height = initial_height
	_current_width = initial_width
	for w in range(initial_width):
		grid_slots[w] = {}
		for h in range(initial_height):
			grid_slots[w][h] = null

func get_height():
	return _current_height
	
func get_width():
	return _current_width
