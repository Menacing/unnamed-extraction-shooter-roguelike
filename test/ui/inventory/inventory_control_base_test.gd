# GdUnit generated TestSuite
class_name InventoryControlBaseTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://ui/inventory/inventory_control_base.gd'

var player_inventory_scene:PackedScene = load("res://ui/inventory/player_inventory.tscn")
var item_info:ItemInformation = load("res://game_objects/items/materials/polymer_pile/polymer_pile_inventory_info.tres")
var test_inventory:Inventory = load("res://test/resource_access/test_inventory.tres")

func before_test():
	InventoryManager._clear_inventories()

func test__on_populate_level() -> void:
	#arrange
	var inventory_control:InventoryControlBase = player_inventory_scene.instantiate()
	self.add_child(inventory_control)
	var item_inst:ItemInstance = ItemInstance.new(item_info)
	
	#act
	EventBus.populate_level.emit()
	item_inst.spawn_item()
	var inventory_control_inventory:Inventory = InventoryAccess.get_inventory(inventory_control.inventory_id)
	InventoryManager._on_pickup_item(item_inst, inventory_control.inventory_id)
	
	#assert
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_object(inventory_control_inventory).is_not_null()
	assert_int(inventory_control.inventory_id).is_not_equal(inventory_control._model_inventory.inventory_id)
	#inventory should have a polymer pile at 0,0
	assert_int(inventory_control_inventory.grid_slots[0][0]).is_equal(item_inst.item_instance_id)
	#control should have a control under the first panel
	var inv_grid = inventory_control.get_inventory_grid()
	assert_object(inv_grid).is_not_null()
	var first_cell = inv_grid.get_child(0)
	assert_object(first_cell).is_not_null()
	assert_int(first_cell.get_child_count()).is_equal(1)
	
func test_set_inventory_picks_up_items() -> void:
	#arrange
	var inventory_control:InventoryControlBase = player_inventory_scene.instantiate()
	self.add_child(inventory_control)
	var item_inst:ItemInstance = ItemInstance.new(item_info)
	var external_inventory = test_inventory.duplicate(true)
	external_inventory.setup()
	inventory_control.inventory_id = external_inventory.inventory_id
	
	#act
	item_inst.spawn_item()
	var inventory_control_inventory:Inventory = InventoryAccess.get_inventory(inventory_control.inventory_id)
	InventoryManager._on_pickup_item(item_inst, inventory_control.inventory_id)
	
	#assert
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_object(inventory_control_inventory).is_not_null()
	assert_int(inventory_control.inventory_id).is_not_equal(inventory_control._model_inventory.inventory_id)
	#inventory should have a polymer pile at 0,0
	assert_int(inventory_control_inventory.grid_slots[0][0]).is_equal(item_inst.item_instance_id)
	#control should have a control under the first panel
	var inv_grid = inventory_control.get_inventory_grid()
	assert_object(inv_grid).is_not_null()
	var first_cell = inv_grid.get_child(0)
	assert_object(first_cell).is_not_null()
	assert_int(first_cell.get_child_count()).is_equal(1)
	
func test_restored_inventories_picks_up_items() -> void:
	#arrange
	var inventory_control:InventoryControlBase = player_inventory_scene.instantiate()
	self.add_child(inventory_control)
	var item_inst:ItemInstance = ItemInstance.new(item_info)
	var external_inventory = test_inventory.duplicate(true)
	external_inventory.setup()
	inventory_control.inventory_id = external_inventory.inventory_id
	
	#act
	item_inst.spawn_item()
	external_inventory.grid_slots[0][0] = item_inst.item_instance_id
	var inventory_control_inventory:Inventory = InventoryAccess.get_inventory(inventory_control.inventory_id)
	InventoryManager._restore_inventories()
	
	#assert
	assert_int(InventoryAccess.inventories.size()).is_equal(1)
	assert_object(inventory_control_inventory).is_not_null()
	assert_int(inventory_control.inventory_id).is_not_equal(inventory_control._model_inventory.inventory_id)
	#inventory should have a polymer pile at 0,0
	assert_int(inventory_control_inventory.grid_slots[0][0]).is_equal(item_inst.item_instance_id)
	#control should have a control under the first panel
	var inv_grid = inventory_control.get_inventory_grid()
	assert_object(inv_grid).is_not_null()
	var first_cell = inv_grid.get_child(0)
	assert_object(first_cell).is_not_null()
	assert_int(first_cell.get_child_count()).is_equal(1)
	
func after_test():
	InventoryManager._clear_inventories()
