# GdUnit generated TestSuite
class_name InventoryAccessTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://resource_access/inventory_access.gd'

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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	var item:ItemInstance = ItemInstance.new(item_info)
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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	var item:ItemInstance = ItemInstance.new(item_info)
	item.stacks = 1
	
	var place_result = inventory_access.place_item_in_slot(item, test_inventory_id, "test_slot_1")
	
	var item2:ItemInstance = ItemInstance.new(item_info)
	item2.stacks = 1
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.can_place_stack_in_slot(item2, test_inventory_id, "test_slot_1")

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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	var item:ItemInstance = ItemInstance.new(item_info)
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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 1)
	
	var item2:ItemInstance = ItemInstance.new(item_info)
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
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_slot(item, test_inventory_id, "test_slot_1", 1)
	
	var item2:ItemInstance = ItemInstance.new(item_info)
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

func test_can_place_item_in_grid_occupied() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	

	test_inventory.grid_slots[0][0] = item

	#act
	var result = inventory_access.can_place_item_in_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_false()
	inventory_access._clear_inventory(test_inventory_id)


func test_can_place_item_in_grid_empty() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")

	var item:ItemInstance = ItemInstance.new(item_info)
	

	#act
	var result = inventory_access.can_place_item_in_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_true()
	inventory_access._clear_inventory(test_inventory_id)
	
func test_can_place_item_in_grid_bad_pos() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	

	#act
	var result = inventory_access.can_place_item_in_grid(item, test_inventory.get_instance_id(), Vector2i(-10,0))

	#assert
	assert_bool(result).is_false()
	inventory_access._clear_inventory(test_inventory_id)
	
func test_can_place_item_in_grid_item_too_big() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 45
	item_info.column_span = 20
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	

	#act
	var result = inventory_access.can_place_item_in_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_false()
	inventory_access._clear_inventory(test_inventory_id)

func test_place_item_in_grid_empty() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	

	#act
	var result = inventory_access.place_item_in_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_true()
	assert_object(test_inventory.grid_slots[0][0]).is_equal(item)
	assert_object(test_inventory.grid_slots[1][0]).is_equal(item)
	inventory_access._clear_inventory(test_inventory_id)

func test_can_place_stack_in_grid_empty() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 1
	#act
	var result = inventory_access.can_place_stack_in_grid(item, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_true()
	inventory_access._clear_inventory(test_inventory_id)
func test_can_place_stack_in_grid_occupied() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 1
	
	test_inventory.grid_slots[0][0] = item
	
	var item2 = ItemAccess.clone_instance(item)
	
	#act
	var result = inventory_access.can_place_stack_in_grid(item2, test_inventory.get_instance_id(), Vector2i(0,0))

	#assert
	assert_bool(result).is_true()
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_empty_grid_whole_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 1
	
	#act
	var place_result = inventory_access.place_stack_in_grid(item, test_inventory_id, Vector2i(0,0), 1)

	#assert
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.grid_slots[0][0].get_instance_id())
	assert_int(item.stacks).is_equal(1)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_empty_grid_half_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 4
	
	#act
	var place_result = inventory_access.place_stack_in_grid(item, test_inventory_id, Vector2i(0,0), 2)

	#assert
	assert_bool(place_result).is_false()
	assert_int(item.get_instance_id()).is_not_equal(test_inventory.grid_slots[0][0].get_instance_id())
	assert_int(item.stacks).is_equal(2)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_occupied_grid_whole_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_grid(item, test_inventory_id, Vector2i(0,0), 1)
	
	var item2:ItemInstance = ItemInstance.new(item_info)
	item2._item_info = item_info
	item2.stacks = 1
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.place_stack_in_grid(item2, test_inventory_id, Vector2i(0,0), 1)

	#assert
	assert_bool(result).is_true()
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.grid_slots[0][0].get_instance_id())
	assert_int(item.stacks).is_equal(2)
	assert_int(item2.stacks).is_equal(0)
	inventory_access._clear_inventory(test_inventory_id)

func test_place_stack_in_occupied_grid_half_stack() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 10
	item_info.has_stacks = true
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	item.stacks = 1
	
	var place_result = inventory_access.place_stack_in_grid(item, test_inventory_id, Vector2i(0,0), 1)
	
	var item2:ItemInstance = ItemInstance.new(item_info)
	item2._item_info = item_info
	item2.stacks = 2
	var item2_has_stacks = item2.get_has_stacks()
	var item2_id = item2.get_instance_id()
	#act
	var result = inventory_access.place_stack_in_grid(item2, test_inventory_id, Vector2i(0,0), 1)

	#assert
	assert_bool(result).is_false()
	assert_bool(place_result).is_true()
	assert_int(item.get_instance_id()).is_equal(test_inventory.grid_slots[0][0].get_instance_id())
	assert_int(item.stacks).is_equal(2)
	assert_int(item2.stacks).is_equal(1)
	inventory_access._clear_inventory(test_inventory_id)


func test_remove_item_from_grid() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	
	
	test_inventory.grid_slots[0][0] = item
	test_inventory.grid_slots[1][0] = item
	assert_object(test_inventory.grid_slots[0][0]).is_equal(item)
	assert_object(test_inventory.grid_slots[1][0]).is_equal(item)

	#act
	inventory_access.remove_item_from_grid(item, test_inventory.get_instance_id())

	#assert
	assert_object(test_inventory.grid_slots[0][0]).is_null()
	assert_object(test_inventory.grid_slots[1][0]).is_null()
	inventory_access._clear_inventory(test_inventory_id)


func test_remove_item() -> void:
	#arrange
	var inventory_access = InventoryAccess.new()
	var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")
	test_inventory.setup()
	inventory_access.add_inventory(test_inventory)
	var test_inventory_id:int = test_inventory.get_instance_id()
	
	var item_info:ItemInformation = ItemInformation.new()
	item_info.row_span = 1
	item_info.column_span = 2
	item_info.item_type = GameplayEnums.ItemType.GUN
	item_info.display_name = "AK47"
	item_info.item_type_id = 1
	item_info.max_stacks = 1
	item_info.icon = load("res://Scenes/Guns/AK47-Projectile/ak48_img.png")
	item_info.icon_r = load("res://Scenes/Guns/AK47-Projectile/ak48_img_r.png")
	var item:ItemInstance = ItemInstance.new(item_info)

	var item2:ItemInstance = ItemInstance.new(item_info)
	
	test_inventory.grid_slots[0][0] = item
	test_inventory.grid_slots[1][0] = item
	test_inventory.equipment_slots[0].item_instance_id = item2.get_instance_id()
	
	assert_object(test_inventory.grid_slots[0][0]).is_equal(item)
	assert_object(test_inventory.grid_slots[1][0]).is_equal(item)
	assert_int(test_inventory.equipment_slots[0].item_instance_id).is_equal(item2.get_instance_id())

	#act
	inventory_access.remove_item(item, test_inventory.get_instance_id())
	inventory_access.remove_item(item2, test_inventory.get_instance_id())

	#assert
	assert_object(test_inventory.grid_slots[0][0]).is_null()
	assert_object(test_inventory.grid_slots[1][0]).is_null()
	assert_int(test_inventory.equipment_slots[0].item_instance_id).is_equal(0)	
	inventory_access._clear_inventory(test_inventory_id)
