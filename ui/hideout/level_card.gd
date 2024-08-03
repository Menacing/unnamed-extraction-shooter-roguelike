extends Control
class_name LevelCard

var level_information:LevelInformation

@onready var title_label:Label = %TitleLabel
@onready var preview_rect:TextureRect = %PreviewTextureRect
@onready var biome_label:Label = %BiomeLabel
@onready var size_label:Label = %SizeLabel
@onready var desc_label:Label = %DescriptionLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if level_information:
		title_label.text = level_information.display_name
		preview_rect.texture = level_information.preview_image
		biome_label.text = LevelInformation.get_biome_string(level_information.biome)
		size_label.text = LevelInformation.get_size_string(level_information.size)
		pass # Replace with function body.


