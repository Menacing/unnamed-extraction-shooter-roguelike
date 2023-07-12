extends Resource
class_name ItemInformation

enum ItemType {
	GUN,
	BACKPACK,
	MATERIAL,
	ARMOR
}

@export var item_type_id:int
@export var show_name:bool = false
@export var display_name:String
@export var item_type:ItemType
@export var icon:Texture
@export var icon_r:Texture
#@export var mod_slots:Array[ModSlot]
@export var detail_scene:PackedScene
#@export var context_menu_items:Array[ItemContextItem]
@export var max_stacks:int = 1
@export var max_durability:int = 1
@export var column_span:int = 1
@export var row_span:int = 1
@export_multiline var tooltip_text:String
