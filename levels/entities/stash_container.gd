@tool
class_name StashContainer
extends GeoBallisticSolid

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")

signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData

func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_stash.emit()

@export var container_size:int

func _ready():
	inventory_data.set_inventory_size(container_size)
	HideoutManager.inventory_data = inventory_data
	#if Engine.is_editor_hint():
		#return
	##do ballistic solid stuff
	#super()
	##instantiate inventory control
	#hideout_menu = HideoutManager.hideout_menu
	#stash_inventory = hideout_menu.stash_inventory_control
	#self.add_child(stash_inventory)
	#
	##setup inventory linkages
	#stash_inventory.container_size = container_size
	#EventBus.item_picked_up.connect(_on_item_picked_up)
	#Helpers.apply_material_overlay_to_children(self, item_highlight_m)
	#EventBus.game_saving.connect(_on_game_saving)
#
#func _on_game_saving(save_file:SaveFile):
	#var save_data:LevelEntitySaveData = LevelEntitySaveData.new()
	#save_data.node_path = self.get_path()
	#save_data.additional_data["inventory_id"] = stash_inventory.inventory_id
	#save_file.level_entity_save_data.append(save_data)
	#pass
#
#func _on_load_game(save_data:LevelEntitySaveData):
	#stash_inventory.inventory_id = save_data.additional_data["inventory_id"]
#
#func use(player:Player):
	#if stash_inventory.visible:
		#player.close_inventory()
		#EventBus.close_inventory.emit(stash_inventory.inventory_id)
	#else:
		#player.open_inventory()
		#EventBus.open_inventory.emit(stash_inventory.inventory_id)
#
#func on_inv_closed(player:Player):
	#EventBus.close_inventory.emit(stash_inventory.inventory_id)
#
#
#func _on_item_picked_up(result:InventoryInsertResult):
	#if result.inventory_id == stash_inventory.inventory_id:
		#var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		#var item_3d:Item3D = ItemAccess.get_item_3d(item_instance.id_3d)
		#Helpers.force_parent(item_3d,self)
		#item_3d.picked_up()
		#item_3d.visible = false
