extends Control
class_name InventoryControlBase

@export var _model_inventory:Inventory
var _inventory:Inventory
@export var _inventory_grid_path:NodePath
@export var _inventory_container_path:NodePath
var _inventory_container:Control

func get_inventory_grid() -> InventoryGridContainer:
	if _inventory_grid_path:
		return get_node(_inventory_grid_path)
	else:
		return null

var inventory_id:int :
	get:
		return inventory_id
	set(value):
		pass
		#var inv:Inventory = InventoryAccess.get_inventory(value)
		#if inv:
			#if !inv._is_setup:
				#inv.setup()
			#_inventory = inv
			#inventory_id = inv.inventory_id

func _ready():
	#EventBus.open_inventory.connect(_on_open_inventory)
	#EventBus.close_inventory.connect(_on_close_inventory)
	#EventBus.close_all_inventories.connect(_on_close_all_inventories)
	#EventBus.item_removed_from_inventory.connect(_on_item_removed_from_inventory)
	#EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.before_populate_level.connect(_on_before_populate_level)
	_inventory_container = get_node(_inventory_container_path)
	
	
func _on_before_populate_level():
	setup_inventory_from_model()
	
func setup_inventory_from_model():
	#check if the inventory is already set up otherwise we lose the inventory on changing maps
	if _inventory == null:
		_inventory = _model_inventory.duplicate(true)
		_inventory.setup()
		inventory_id = _inventory.inventory_id

func _on_item_picked_up(result:InventoryInsertResult):
	pass
	#if result.inventory_id == _inventory.inventory_id and result.picked_up:
		#var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		#var item_control:ItemControl = ItemAccess.get_item_control(item_instance.id_2d)
		#var location = result.location
		#if location.location == InventoryLocationResult.LocationType.SLOT:
			#var slot_type:EquipmentSlotType = Inventory.get_slot_by_name(_inventory, location.slot_name)
			#if slot_type:
				#var slot_control = self.find_child(slot_type.name)
				#if slot_control:
					#slot_control.add_item_control(item_control)
		#elif location.location == InventoryLocationResult.LocationType.GRID and get_inventory_grid():
			#get_inventory_grid().add_item_control(item_control, location.grid_x, location.grid_y)

func _on_open_inventory(in_inventory_id:int):
	if in_inventory_id == self.inventory_id:
		if _inventory_container:
			_inventory_container.visible = true
		else:
			visible = true
		
func _on_close_inventory(in_inventory_id:int):
	if in_inventory_id == self.inventory_id:
		if _inventory_container:
			_inventory_container.visible = false
		else:
			visible = false

func _on_close_all_inventories():
	if _inventory_container:
		_inventory_container.visible = false
	else:
		visible = false

func _on_item_removed_from_inventory(item_inst:ItemInstance, in_inventory_id:int):
	pass
	#if in_inventory_id == _inventory.inventory_id:
		#var item_control:ItemControl = ItemAccess.get_item_control(item_inst.id_2d)
		#if item_control:
			#var parent = item_control.get_parent()
			#if parent:
				#parent.remove_child(item_control)
