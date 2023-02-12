extends Node

class_name ItemComponent

enum ItemType {
	GUN
}

@export var id:String
@export var type:ItemType
@export var icon:Texture
@export var stack:int
@export var max_stack:int
@export var column:int
@export var column_span:int
@export var row:int
@export var row_span:int
var node_id:int:
	get:
		return get_parent().get_instance_id()
	set(value):
		pass

var idata_keys:Array = ["id",
		"type",
		"icon",
		"stack",
		"max_stack",
		"column",
		"column_span",
		"row",
		"row_span",
		"node_id"]

var idata:Dictionary:
	get:
		var dict = {}
		for key in idata_keys:
			var val = self.get(key)
			if val:
				dict[key] = val
		return dict
	set(value):
		for key in idata_keys:
			if value.has(key):
				self.set(key,value[key])
