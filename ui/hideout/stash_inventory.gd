extends MarginContainer

func _ready() -> void:
	$VBoxContainer/UpgradeHBoxContainer.upgrade_triggered.connect(HideoutManager._on_stash_upgraded)
