@tool
extends VBoxContainer
class_name UpgradeContainerControl

const STASH_MATERIAL_ENTRY = preload("res://ui/hideout/stash_material_entry.tscn")

signal upgrade_triggered

@export var upgrade_requirement:UpgradeRequirement:
	set(value):
		upgrade_requirement = value
		if value:
			for child in $ScrollContainer/HBoxContainer.get_children():
				child.queue_free()
			for req in value.required_materials:
				var mat_entry_control = STASH_MATERIAL_ENTRY.instantiate()
				mat_entry_control.set_crafting_material(req.material, req.amount)
				$ScrollContainer/HBoxContainer.add_child(mat_entry_control)
				if Engine.is_editor_hint():
					mat_entry_control.owner = get_tree().edited_scene_root
			$UpgradeButton.disabled = !is_upgrade_available()
	get:
		return upgrade_requirement

func _ready() -> void:
	EventBus.material_changed.connect(_on_material_changed)
	
func _on_material_changed(crafting_material_entry:CraftingMaterialEntry):
	$UpgradeButton.disabled = !is_upgrade_available()

func is_upgrade_available() -> bool:
	if upgrade_requirement:
		for req in upgrade_requirement.required_materials:
			if req.amount > HideoutManager.get_crafting_material_amount(req.material.name):
				return false
	return true
	


func _on_upgrade_button_pressed() -> void:
	if upgrade_requirement:
		for req in upgrade_requirement.required_materials:
			HideoutManager.remove_crafting_material(req.material.name, req.amount)
		
	upgrade_triggered.emit()
	pass # Replace with function body.
