extends InventoryControlBase
class_name StashInventory

@export var polymer_count_label:Label
@export var scrap_metal_count_label:Label
@export var bio_gel_count_label:Label

var sig:StashInventoryGrid
var container_size:int:
	get:
		return sig.container_size
	set(value):
		sig.container_size = value
		sig.set_grid_container_size(value)
		
@onready var original_parent:Node = self.get_parent()
var player:Player

@export var hideout_menu:HideoutMenu

func _ready():
	super()
	#EventBus.drop_item.connect(_on_drop_item)
	#sig = get_node(_inventory_grid_path)
	#
	#for cme:CraftingMaterialEntry in HideoutManager.crafting_materials:
		#if cme.material_definition.name == "Polymer":
			#cme.amount_changed.connect(_on_crafting_material_entry_amount_changed.bind(polymer_count_label))
		#if cme.material_definition.name == "Scrap Metal":
			#cme.amount_changed.connect(_on_crafting_material_entry_amount_changed.bind(scrap_metal_count_label))
		#if cme.material_definition.name == "Bio Gel":
			#cme.amount_changed.connect(_on_crafting_material_entry_amount_changed.bind(bio_gel_count_label))
		#pass
	
func _on_crafting_material_entry_amount_changed(new_amount:int, label:Label):
	label.text = str(new_amount)
	
func _on_before_populate_level():
	super()
	container_size = _inventory.initial_height * _inventory.initial_width

func _on_item_picked_up(result:InventoryInsertResult):
	if result.inventory_id == _inventory.inventory_id and result.picked_up:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_control:ItemControl = ItemAccess.get_item_control(item_instance.id_2d)
		var location = result.location
		if location.location == InventoryLocationResult.LocationType.GRID:
			sig.add_item_control(item_control, location.grid_x, location.grid_y)
			
		if item_instance.get_item_type() == GameplayEnums.ItemType.MATERIAL:
			var remainder:int = HideoutManager.add_crafting_material_item_instance(item_instance)
			item_instance.stacks = remainder

func _on_open_inventory(inventory_id:int):
	super(inventory_id)
	if inventory_id == self.inventory_id:
		hideout_menu.visible = true
		EventBus.add_control_to_HUD.emit(hideout_menu)
		hideout_menu.show_stash_tab()
		
func _on_close_inventory(inventory_id:int):
	super(inventory_id)
	if inventory_id == self.inventory_id:
		EventBus.remove_control_from_HUD.emit(hideout_menu, original_parent)

func _on_close_all_inventories():
	super()
	EventBus.remove_control_from_HUD.emit(hideout_menu, original_parent)
	
func _on_drop_item(item_inst:ItemInstance, _inventory_id:int):
	if _inventory_id == self.inventory_id:
		var item_3d:Item3D = ItemAccess.get_item_3d(item_inst.id_3d)
		Helpers.force_parent(item_3d,get_parent())
		item_3d.dropped()
		var aabb = Helpers.get_aabb_of_node(self)
		item_3d.global_position = player.drop_location.global_position
