@tool
extends VBoxContainer
class_name PrintContainerControl

const STASH_MATERIAL_ENTRY = preload("res://ui/hideout/stash_material_entry.tscn")

@export var required_materials:Array[UpgradeMaterialEntry]:
	set(value):
		required_materials = value
		if value:
			for child in $ScrollContainer/HBoxContainer.get_children():
				child.queue_free()
			for req in required_materials:
				var mat_entry_control = STASH_MATERIAL_ENTRY.instantiate()
				mat_entry_control.set_crafting_material(req.material, req.amount)
				$ScrollContainer/HBoxContainer.add_child(mat_entry_control)
				if Engine.is_editor_hint():
					mat_entry_control.owner = get_tree().edited_scene_root
			$PrintButton.disabled = !is_print_available()
	get:
		return required_materials

@export var display_name:String:
	get:
		return display_name
	set(value):
		display_name = value
		$Label.text = display_name
@export var item_to_print:ItemInformation
@export var required_printer_size:PrinterStation.PrinterSize

func _ready() -> void:
	EventBus.material_changed.connect(_on_material_changed)
	HideoutManager.printer_size_changed.connect(_on_printer_size_changed)
	$PrintButton.disabled = !is_print_available()
	
func _on_material_changed(crafting_material_entry:CraftingMaterialEntry):
	$PrintButton.disabled = !is_print_available()

func _on_printer_size_changed():
	$PrintButton.disabled = !is_print_available()

func is_print_available() -> bool:
	if required_printer_size > HideoutManager.current_printer_size:
		return false
	if required_materials:
		for req in required_materials:
			if req.amount > HideoutManager.get_crafting_material_amount(req.material.name):
				return false
	return true
	


func _on_print_button_pressed() -> void:
	if required_materials:
		for req in required_materials:
			HideoutManager.remove_crafting_material(req.material.name, req.amount)
		
	HideoutManager.print_item.emit(item_to_print)
	pass # Replace with function body.
