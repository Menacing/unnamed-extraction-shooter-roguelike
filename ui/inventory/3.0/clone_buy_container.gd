@tool
extends VBoxContainer
class_name CloneBuyContainerControl

const STASH_MATERIAL_ENTRY = preload("res://ui/hideout/stash_material_entry.tscn")
@onready var scroll_container: ScrollContainer = $ScrollContainer

signal upgrade_triggered

@export var upgrade_requirement:UpgradeRequirement

func _ready() -> void:
	EventBus.material_changed.connect(_on_material_changed)
	
	if upgrade_requirement:
		for child in scroll_container.get_children():
			child.queue_free()
		for req in upgrade_requirement.required_materials:
			var mat_entry_control = STASH_MATERIAL_ENTRY.instantiate()
			mat_entry_control.set_crafting_material(req.material, req.amount)
			scroll_container.add_child(mat_entry_control)
			if Engine.is_editor_hint():
				mat_entry_control.owner = get_tree().edited_scene_root
	_on_material_changed(null)
	
func _on_material_changed(crafting_material_entry:CraftingMaterialEntry):
	$UpgradeButton.disabled = !is_upgrade_available()

func is_upgrade_available() -> bool:
	if !HideoutManager.in_hideout:
		return false
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
