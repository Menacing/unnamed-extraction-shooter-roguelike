extends Resource
class_name InventoryItemInfo

enum ItemType {
	GUN,
	BACKPACK,
	MATERIAL,
	ARMOR
}

@export var show_name:bool = false
@export var display_name:String
@export var item_type:ItemType
@export var icon:Texture
@export var icon_r:Texture
@export var mod_slots:Array[ModSlot]
@export var detail_scene:PackedScene
@export var context_menu_items:Array[ItemContextItem]
@export var max_stacks:int
@export var max_durability:int
@export var column_span:int
@export var row_span:int
@export_multiline var tooltip_text:String
