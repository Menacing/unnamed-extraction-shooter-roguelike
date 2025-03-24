@tool
extends PanelContainer

func set_crafting_material(mat_def:CraftingMaterialDefinition, amount:int) -> void:
	$HBoxContainer/MarginContainer/TextureRect.texture = mat_def.icon
	$HBoxContainer/MarginContainer2/Label.text = str(amount)
