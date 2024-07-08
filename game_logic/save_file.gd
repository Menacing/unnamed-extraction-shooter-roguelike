extends Resource
class_name SaveFile

@export var game_version:String
@export var level_scene_path:String

#things to save
@export var save_data:Array[WorldEntitySaveData] = []

#all inventories
@export var inventories:Array[Inventory] = []

#enemies

#world items
