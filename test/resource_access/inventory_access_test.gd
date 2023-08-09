# GdUnit generated TestSuite
class_name InventoryAccessTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/inventory_access.gd'


#func test__can_place_item_at_grid() -> void:
	##arrange
	#var inventory_access = InventoryAccess.new()
	#var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	#test_inventory.setup()
	#inventory_access.add_inventory(test_inventory)
	#var item:ItemInstance = ItemInstance.new()
	#var item_info:ItemInformation = ItemInformation.new()
	#item_info.row_span = 1
	#item_info.column_span = 2
	#item_info.item_type = ItemInformation.ItemType.GUN
	#item_info.display_name = "AK47"
	#item_info.item_type_id = 1
	#item_info.max_stacks = 1
	#item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	#item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
#
	#item._item_info = item_info
	#item.stacks = 1
#
	#inventory_access.place_item_at_grid(item, test_inventory, Vector2i(0,0),0)
#
	##act
	#var result = inventory_access.can_place_item_at_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))
#
	##assert
	#assert_bool(result).is_false()
#
#func test__can_place_item_at_grid_combined_stacks() -> void:
	##arrange
	#var inventory_access = InventoryAccess.new()
	#var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	#test_inventory.setup()
	#inventory_access.add_inventory(test_inventory)
	#var item1:ItemInstance = ItemInstance.new()
	#var item_info:ItemInformation = ItemInformation.new()
	#item_info.row_span = 1
	#item_info.column_span = 2
	#item_info.item_type = ItemInformation.ItemType.GUN
	#item_info.display_name = "AK47"
	#item_info.item_type_id = 1
	#item_info.max_stacks = 5
	#item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	#item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
#
	#item1._item_info = item_info
	#item1.stacks = 1
#
	#test_inventory.grid_slots[0][0] = item1
#
	#var item2:ItemInstance = ItemInstance.new()
	#item2._item_info = item_info
	#item2.stacks = 3
#
	##act
	#var result = inventory_access.place_item_at_grid(item2, test_inventory, Vector2i(0,0),1)
	#var test_result = result.status == InventoryInsertResult.PickupItemResult.STACK_COMBINED
#
	##assert
	#assert_bool(test_result).is_true()
#
#func test__can_place_item_at_empty_grid_created_stacks() -> void:
	##arrange
	#var inventory_access = InventoryAccess.new()
	#var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	#test_inventory.setup()
	#inventory_access.add_inventory(test_inventory)
	#var item1:ItemInstance = ItemInstance.new()
	#var item_info:ItemInformation = ItemInformation.new()
	#item_info.row_span = 1
	#item_info.column_span = 2
	#item_info.item_type = ItemInformation.ItemType.GUN
	#item_info.display_name = "AK47"
	#item_info.item_type_id = 1
	#item_info.max_stacks = 5
	#item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	#item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
#
	#item1._item_info = item_info
	#item1.stacks = 3
#
	##act
	#var result = inventory_access.place_item_at_grid(item1, test_inventory, Vector2i(0,0),1)
	#var test_result = result.status == InventoryInsertResult.PickupItemResult.STACK_CREATED
#
	##assert
	#assert_bool(test_result).is_true()

##---------------------------------------------------------------------
#REMEMBER THE INVENTORY STATE CARRIES ACROSS TESTS UNLESS YOU EXPLICITLY CLEAR IT
##---------------------------------------------------------------------

func test_can_place_item_in_slot() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
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

	#act
	var result = inventory_access.can_place_item_in_slot(item, test_inventory_id, "test_slot_1")

	#assert
	assert_bool(result).is_true()
	inventory_access._clear_inventory(test_inventory_id)
	
func test__clear_inventory() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
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

	#act
	var result = inventory_access.can_place_item_in_slot(item, test_inventory_id, "test_slot_1")
	inventory_access._clear_inventory(test_inventory_id)
	var result_inv = inventory_access.get_inventory(test_inventory_id)
	
	#assert
	assert_int(result_inv.equipment_slots[0].item_instance_id).is_equal(0)

func test_place_item_in_slot() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
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

	#act
	var result:bool = inventory_access.place_item_in_slot(item, test_inventory_id, "test_slot_1")

	#assert
	assert_bool(result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.equipment_slots[0].item_instance_id)
	inventory_access._clear_inventory(test_inventory_id)

func test_can_place_stack_in_slot() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	item._item_info = item_info
	item.stacks = 1
	
	var place_result = inventory_access.place_item_in_slot(item, test_inventory_id, "test_slot_1")
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 1
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.can_place_stack_in_slot(item2, test_inventory_id, "test_slot_1", 1)

	#assert
	assert_bool(result).is_true()
	inventory_access._clear_inventory(test_inventory_id)
	
func test_place_stack_in_empty_slot_whole_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	item._item_info = item_info
	item.stacks = 1
	
	#act
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 1)

	#assert
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.equipment_slots[0].item_instance_id)
	assert_int(item.stacks).is_equal(1)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_empty_slot_half_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	item._item_info = item_info
	item.stacks = 4
	
	#act
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 2)

	#assert
	assert_bool(place_result).is_false()
	assert_int(item.get_instance_id()).is_not_equal(test_inventory.equipment_slots[0].item_instance_id)
	assert_int(item.stacks).is_equal(2)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_occupied_slot_whole_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	item._item_info = item_info
	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 1)
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 1
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.place_stack_in_slot(item2, test_inventory_id, "test_slot_1", 1)

	#assert
	assert_bool(result).is_true()
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.equipment_slots[0].item_instance_id)
	assert_int(item.stacks).is_equal(2)
	assert_int(item2.stacks).is_equal(0)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_occupied_slot_half_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item:ItemInstance = ItemInstance.new()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = ItemInformation.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	item._item_info = item_info
	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 1)
	
	var item2:ItemInstance = ItemInstance.new()
	item2._item_info = item_info
	item2.stacks = 2
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.place_stack_in_slot(item2, test_inventory_id, "test_slot_1", 1)

	#assert
	assert_bool(result).is_false()
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.equipment_slots[0].item_instance_id)
	assert_int(item.stacks).is_equal(2)
	assert_int(item2.stacks).is_equal(1)
	inventory_access._clear_inventory(test_inventory_id)
