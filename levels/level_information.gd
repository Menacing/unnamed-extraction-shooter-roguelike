extends Resource
class_name LevelInformation

enum Biome {WODC, EASI, CENT, Neutral}
enum Size {Small, Medium, Large}

@export var level_path:String
@export var display_name:String
@export var biome:Biome
@export var size:Size
@export var preview_image:Texture
@export var description:String

static func get_biome_string(biome:Biome):
	match biome:
		Biome.WODC:
			return "WODC"
		Biome.EASI:
			return "EASI"
		Biome.CENT:
			return "CENT"
		Biome.Neutral:
			return "Neutral"
			
static func get_size_string(size:Size):
	match size:
		Size.Small:
			return "Small"
		Size.Medium:
			return "Medium"
		Size.Large:
			return "Large"
