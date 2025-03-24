extends ScrollContainer

const STASH_MATERIAL_ENTRY = preload("res://ui/hideout/stash_material_entry.tscn")

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	for material:CraftingMaterialEntry in HideoutManager.crafting_materials:
		if material.material_definition.icon:
			var material_entry_scene = STASH_MATERIAL_ENTRY.instantiate()
			material_entry_scene.set_crafting_material(material.material_definition, material.amount)
			material.amount_changed.connect(material_entry_scene.set_amount)
			h_box_container.add_child(material_entry_scene)
