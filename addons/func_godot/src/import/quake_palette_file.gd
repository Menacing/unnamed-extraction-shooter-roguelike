@icon("res://addons/func_godot/icons/icon_quake_file.svg")
extends Resource
class_name QuakePaletteFile

@export var colors: PackedColorArray

func _init(colors):
	self.colors = colors
