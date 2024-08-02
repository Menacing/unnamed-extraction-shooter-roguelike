extends Resource
class_name LevelInformation

enum Biome {WODC, EASI, CENT, Neutral}
enum Size {Small, Medium, Large}

@export var level:PackedScene
@export var display_name:String
@export var biome:Biome
@export var size:Size
@export var preview_image:ImageTexture
@export var description:String
