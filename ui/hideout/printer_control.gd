extends MarginContainer

const MEDIUM_PRINTER_REQUIREMENTS = preload("res://game_objects/props/printers/medium_printer_requirements.tres")
@onready var upgrade_h_box_container: UpgradeContainerControl = $VBoxContainer/UpgradeHBoxContainer

func _ready() -> void:
	upgrade_h_box_container.upgrade_triggered.connect(HideoutManager._on_printer_upgraded)
	HideoutManager.printer_size_changed.connect(_on_printer_upgraded)
	

func _on_printer_upgraded():
		match HideoutManager.current_printer_size:
			PrinterStation.PrinterSize.UNBUILT:
				pass
			PrinterStation.PrinterSize.SMALL:
				upgrade_h_box_container.upgrade_requirement = MEDIUM_PRINTER_REQUIREMENTS
			PrinterStation.PrinterSize.MEDIUM:
				pass
