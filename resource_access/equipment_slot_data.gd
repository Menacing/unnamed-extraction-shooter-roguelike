extends Resource
class_name EquipmentSlot

@export var slot_name:String
@export var allowed_types:Array[GameplayEnums.ItemType]
##Slot width, in cells
@export var slot_width:int
##Slot height, in cells
@export var slot_height:int
@export var background_icon:Texture
@export var slot_data:SlotData
