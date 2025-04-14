extends ColorRect

@export var menu_music_stream:AudioStream

@onready var start_button:Button = %StartButton

@onready var short_button:Button = %ShortButton
@onready var medium_l_button:Button = %MediumLengthButton
@onready var long_button:Button = %LongButton

@onready var easy_button:Button = %EasyButton
@onready var medium_d_button:Button = %MediumDifficultyButton
@onready var hard_button:Button = %HardButton

@onready var length_description_label: Label = %LengthDescriptionLabel
@onready var difficulty_description_label: Label = %DifficultyDescriptionLabel

var short_description:String = "-3 Extracts
-15-30 minutes"

var medium_description:String = "-5 Extracts
-30-45 minutes"

var long_description:String = "-7 Extracts
-45-60 minutes"

var easy_description:String = "-Starting Items
-Normal Loot
-Normal Enemies"

var medium_diff_description:String = "-Fewer Starting Items
-Less Loot
-More Enemies"

var hard_description:String = "-No Starting Items
-Least Loot
-Most Enemies"

func is_length_selected() -> bool:
	var sb = short_button.button_pressed
	var mb = medium_l_button.button_pressed
	var lb = long_button.button_pressed
	return sb or mb or lb
	
func is_difficulty_selected() -> bool:
	var eb = easy_button.button_pressed
	var mb = medium_d_button.button_pressed
	var hb = hard_button.button_pressed
	return eb or mb or hb

func _on_short_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false
	
	medium_l_button.set_pressed_no_signal(false)
	long_button.set_pressed_no_signal(false)
		
	HideoutManager.selected_run_length = GameplayEnums.GameLength.SHORT
	length_description_label.text = short_description


func _on_medium_length_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false
		
	short_button.set_pressed_no_signal(false)
	long_button.set_pressed_no_signal(false)
	
	HideoutManager.selected_run_length = GameplayEnums.GameLength.MEDIUM
	length_description_label.text = medium_description


func _on_long_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false

	short_button.set_pressed_no_signal(false)
	medium_l_button.set_pressed_no_signal(false)
	
	HideoutManager.selected_run_length = GameplayEnums.GameLength.LONG
	length_description_label.text = long_description


func _on_easy_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false
		
	medium_d_button.set_pressed_no_signal(false)
	hard_button.set_pressed_no_signal(false)

	HideoutManager.selected_difficulty = GameplayEnums.GameDifficulty.EASY
	difficulty_description_label.text = easy_description

func _on_medium_difficulty_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false

	easy_button.set_pressed_no_signal(false)
	hard_button.set_pressed_no_signal(false)
	
	HideoutManager.selected_difficulty = GameplayEnums.GameDifficulty.MEDIUM
	difficulty_description_label.text = medium_diff_description


func _on_hard_button_pressed() -> void:
	if is_length_selected() and is_difficulty_selected():
		start_button.disabled = false

	easy_button.set_pressed_no_signal(false)
	medium_d_button.set_pressed_no_signal(false)
	
	HideoutManager.selected_difficulty = GameplayEnums.GameDifficulty.HARD
	difficulty_description_label.text = hard_description


func _on_back_button_pressed() -> void:
	MenuManager.load_menu(MenuManager.previous_menu_level)


func _on_start_button_pressed() -> void:
	match HideoutManager.selected_difficulty:
		GameplayEnums.GameDifficulty.EASY:
			HideoutManager.remaining_lives = 2
		GameplayEnums.GameDifficulty.MEDIUM:
			HideoutManager.remaining_lives = 1
		GameplayEnums.GameDifficulty.HARD:
			HideoutManager.remaining_lives = 0
			
	await LevelManager.load_hideout_async()
	MenuManager.load_menu(MenuManager.MENU_LEVEL.NONE)
