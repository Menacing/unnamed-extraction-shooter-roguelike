@icon("res://addons/func_godot/icons/icon_quake_file.svg")
extends Resource
class_name QuakeWadFile

@export var textures: Dictionary

func _init(textures: Dictionary):
	self.textures = textures
