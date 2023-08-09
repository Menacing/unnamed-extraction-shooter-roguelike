# GdUnit generated TestSuite
class_name InventoryAccessTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/inventory_access.gd'


func test__can_place_item_at_grid() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	
	item._item_info = item_info
	item.stacks = 1
	
	inventory_access.place_item_at_grid(item, test_inventory, Vector2i(0,0),0)
	
	#act
	var result = inventory_access.can_place_item_at_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))
	
	#assert
	assert_bool(result).is_false()
	
func test__can_place_item_at_grid_combined_stacks() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var item1:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	
	item1._item_info = item_info
	item1.stacks = 1
	
	test_inventory.grid_slots[0][0] = item1
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 3
	
	#act
	var result = inventory_access.place_item_at_grid(item2, test_inventory, Vector2i(0,0),1)
	var test_result = result.status == InventoryInsertResult.PickupItemResult.STACK_COMBINED
	
	#assert
	assert_bool(test_result).is_true()
	
func test__can_place_item_at_empty_grid_created_stacks() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var item1:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 5
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	
	item1._item_info = item_info
	item1.stacks = 3
	
	#act
	var result = inventory_access.place_item_at_grid(item1, test_inventory, Vector2i(0,0),1)
	var test_result = result.status == InventoryInsertResult.PickupItemResult.STACK_CREATED
	
	#assert
	assert_bool(test_result).is_true()
