# GdUnit generated TestSuite
class_name CraftingMaterialEntryTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://game_objects/crafting_materials/crafting_material_entry.gd'



func test__sort() -> void:
	#arrange
	var array_to_sort:Array[CraftingMaterialEntry] = []
	
	var common_b := CraftingMaterialDefinition.new()
	common_b.name = "cb"
	common_b.rarity = CraftingMaterialDefinition.Rarity.COMMON
	var common_be := CraftingMaterialEntry.new()
	common_be.material_definition = common_b
	array_to_sort.append(common_be)
	
	var common_a := CraftingMaterialDefinition.new()
	common_a.name = "ca"
	common_a.rarity = CraftingMaterialDefinition.Rarity.COMMON
	var common_ae := CraftingMaterialEntry.new()
	common_ae.material_definition = common_a
	array_to_sort.append(common_ae)
	
	var uncommon_b := CraftingMaterialDefinition.new()
	uncommon_b.name = "ub"
	uncommon_b.rarity = CraftingMaterialDefinition.Rarity.UNCOMMON
	var uncommon_be := CraftingMaterialEntry.new()
	uncommon_be.material_definition = uncommon_b
	array_to_sort.append(uncommon_be)
	
	var uncommon_a := CraftingMaterialDefinition.new()
	uncommon_a.name = "ua"
	uncommon_a.rarity = CraftingMaterialDefinition.Rarity.UNCOMMON
	var uncommon_ae := CraftingMaterialEntry.new()
	uncommon_ae.material_definition = uncommon_a
	array_to_sort.append(uncommon_ae)
	
	var rare_b := CraftingMaterialDefinition.new()
	rare_b.name = "rb"
	rare_b.rarity = CraftingMaterialDefinition.Rarity.RARE
	var rare_be := CraftingMaterialEntry.new()
	rare_be.material_definition = rare_b
	array_to_sort.append(rare_be)
	
	var rare_a := CraftingMaterialDefinition.new()
	rare_a.name = "ra"
	rare_a.rarity = CraftingMaterialDefinition.Rarity.RARE
	var rare_ae := CraftingMaterialEntry.new()
	rare_ae.material_definition = rare_a
	array_to_sort.append(rare_ae)
	
	array_to_sort.shuffle()
	
	#act
	array_to_sort.sort_custom(CraftingMaterialEntry._sort)
	
	#assert
	assert_str(array_to_sort[0].material_definition.name).is_equal("ca")
	assert_str(array_to_sort[1].material_definition.name).is_equal("cb")
	assert_str(array_to_sort[2].material_definition.name).is_equal("ua")
	assert_str(array_to_sort[3].material_definition.name).is_equal("ub")
	assert_str(array_to_sort[4].material_definition.name).is_equal("ra")
	assert_str(array_to_sort[5].material_definition.name).is_equal("rb")

