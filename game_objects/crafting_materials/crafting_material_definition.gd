extends Resource
class_name CraftingMaterialDefinition

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE
}

@export var name:String
@export var rarity:Rarity
@export var icon:Texture2D
