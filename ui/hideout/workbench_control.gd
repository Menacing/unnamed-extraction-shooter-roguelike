extends MarginContainer

@onready var flashlight_upgrade_h_box_container: UpgradeContainerControl = $VBoxContainer/FlashlightUpgradeHBoxContainer


func _ready() -> void:
	if HideoutManager.flashlight_upgraded:
		disable_flashlight_upgrade_button()
func _on_flashlight_upgrade_h_box_container_upgrade_triggered() -> void:
	HideoutManager.flashlight_upgraded = true
	disable_flashlight_upgrade_button()
	pass # Replace with function body.

func disable_flashlight_upgrade_button():
	flashlight_upgrade_h_box_container.queue_free() 
	
