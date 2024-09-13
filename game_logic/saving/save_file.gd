extends Resource
class_name SaveFile

@export var game_version:String
@export var level_scene_path:String

#Hideout information
@export var run_save_data:RunSaveData

#things to save
@export var top_level_entity_save_data:Array[TopLevelEntitySaveData] = []
@export var level_entity_save_data:Array[LevelEntitySaveData] = []
