extends Resource
class_name RunSaveData

@export var next_level_options:Array[LevelInformation] = []
@export var selected_next_level:LevelInformation
@export var game_length:GameplayEnums.GameLength
@export var current_map_number:int
@export var difficulty:GameplayEnums.GameDifficulty
@export var crafting_materials:Array[CraftingMaterialEntry] = []
@export var stash_size:int
@export var printer_level:int
@export var remaining_lives:int
