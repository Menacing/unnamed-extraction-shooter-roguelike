extends Resource
class_name CraftingMaterialEntry

@export var material_definition:CraftingMaterialDefinition
@export var amount:int

##func is called as many times as necessary, receiving two array elements as arguments. The function should return true if the first element should be moved behind the second one, otherwise it should return false.
static func _sort(a:CraftingMaterialEntry, b:CraftingMaterialEntry):
	if a.material_definition.rarity < b.material_definition.rarity:
		return true
	elif a.material_definition.rarity == b.material_definition.rarity:
		return a.material_definition.name < b.material_definition.name
	else:
		return false
