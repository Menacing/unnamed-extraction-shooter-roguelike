extends MarginContainer

func _ready() -> void:
	$VBoxContainer/UpgradeHBoxContainer.upgrade_triggered.connect(HideoutManager._on_printer_upgraded)
