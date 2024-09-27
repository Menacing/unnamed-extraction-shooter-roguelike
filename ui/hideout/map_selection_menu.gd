extends MarginContainer
class_name MapSelectionMenu

@export var level_card_scene:PackedScene

@onready var level_card_container:Control = %LevelCardContainer

var level_options:Array[LevelInformation]

# Called when the node enters the scene tree for the first time.
func _ready():
	if HideoutManager.in_hideout:
		
		level_options = LevelManager.get_level_informations(3)
		
		populate_cards()
		
func populate_cards():
	for n:Node in level_card_container.get_children():
		level_card_container.remove_child(n)
		n.queue_free()
	for level_info:LevelInformation in level_options:
		var card_control:LevelCard = level_card_scene.instantiate()
		card_control.level_information = level_info
		card_control.selected.connect(_on_card_selected)
		level_card_container.add_child(card_control)
		pass

func _on_card_selected(card:LevelCard):
	HideoutManager.next_map = card.level_information
	
	for child in level_card_container.get_children():
		if child == card:
			pass
		else:
			child.deselect()
	
func save_run_data(run_data:RunSaveData):
	run_data.next_level_options = level_options

func load_run_data(run_save_data:RunSaveData):
	level_options = run_save_data.next_level_options
	populate_cards()
	
