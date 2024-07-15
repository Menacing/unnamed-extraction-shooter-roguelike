extends Resource
class_name SaveFile

@export var game_version:String
@export var level_scene_path:String

#things to save
@export var top_level_entity_save_data:Array[TopLevelEntitySaveData] = []
@export var level_entity_save_data:Array[LevelEntitySaveData] = []

#all item instances
@export var item_instances:Array[ItemInstanceSaveData] = []
#all inventories
@export var inventories:Array[Inventory] = []

#enemies

#world items
