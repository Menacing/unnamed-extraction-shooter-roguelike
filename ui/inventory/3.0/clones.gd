extends MarginContainer

@onready var clones_number_label: Label = $VBoxContainer/HBoxContainer/ClonesNumberLabel

func _ready() -> void:
	_on_remaining_lives_changed()
	HideoutManager.lives_changed.connect(_on_remaining_lives_changed)
	pass

func _on_remaining_lives_changed():
	clones_number_label.text = str(HideoutManager.remaining_lives)


func _on_upgrade_h_box_container_upgrade_triggered() -> void:
	HideoutManager.remaining_lives += 1
	pass # Replace with function body.
