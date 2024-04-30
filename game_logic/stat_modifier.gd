extends Resource
class_name StatModifier

enum Operation {
	ADD,
	MUL
}

@export var name:String
@export var operation:Operation
@export var value:float
