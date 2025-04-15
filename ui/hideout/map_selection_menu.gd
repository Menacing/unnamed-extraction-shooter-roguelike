extends MarginContainer
class_name MapSelectionMenu

@export var level_card_scene:PackedScene

@onready var level_card_container:Control = %LevelCardContainer
@onready var previous_level_container: HBoxContainer = %PreviousLevelCardContainer
@onready var previous_level_full_container: VBoxContainer = %PreviousLevelFullContainer


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
	HideoutManager.return_to_previous_level = false
	for child in previous_level_container.get_children():
		child.deselect()
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
	
func populate_previous_level_card():
	for n:Node in previous_level_container.get_children():
		previous_level_container.remove_child(n)
		n.queue_free()
	var level_info = HideoutManager.next_map
	var card_control:LevelCard = level_card_scene.instantiate()
	card_control.level_information = level_info
	card_control.selected.connect(_on_previous_card_selected)
	previous_level_container.add_child(card_control)
	previous_level_full_container.visible = true

func _on_previous_card_selected(card:LevelCard):
	HideoutManager.next_map = card.level_information
	HideoutManager.return_to_previous_level = true
	for child in level_card_container.get_children():
		child.deselect()

func _on_died():
	populate_previous_level_card()
	populate_cards()
	previous_level_full_container.visible = true
	pass
	
func _on_extracted():
	HideoutManager.next_map = null
	populate_cards()
	previous_level_full_container.visible = false
	pass
