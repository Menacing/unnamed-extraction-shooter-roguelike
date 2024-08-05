extends MarginContainer

@export var level_card_scene:PackedScene

@onready var level_card_container:Control = %LevelCardContainer

var selected_level:LevelInformation

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.populate_level.connect(_on_populate_level)
	
	
func _on_populate_level():
	if HideoutManager.in_hideout:
		for n:Node in level_card_container.get_children():
			level_card_container.remove_child(n)
			n.queue_free()
		
		var level_infos:Array[LevelInformation] = LevelManager.get_level_informations(3)
		
		for level_info:LevelInformation in level_infos:
			var card_control:LevelCard = level_card_scene.instantiate()
			card_control.level_information = level_info
			card_control.selected.connect(_on_card_selected)
			level_card_container.add_child(card_control)
			pass


func _on_card_selected(card:LevelCard):
	selected_level = card.level_information
	
	for child in level_card_container.get_children():
		if child == card:
			pass
		else:
			child.deselect()
	
