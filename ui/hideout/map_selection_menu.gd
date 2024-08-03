extends MarginContainer

@export var level_card_scene:PackedScene

@onready var level_card_container:Control = %LevelCardContainer

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
			level_card_container.add_child(card_control)
			pass


