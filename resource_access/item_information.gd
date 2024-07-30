extends Resource
class_name ItemInformation

@export var item_control_scene:PackedScene
@export var item_3d_scene:PackedScene
@export var item_type_id:String
@export var show_name:bool = false
@export var display_name:String
@export var display_short_name:String
@export var item_type:GameplayEnums.ItemType
@export var icon:Texture
@export var icon_r:Texture
@export var item_internal_inventory:Inventory
@export var detail_scene:PackedScene = load("res://ui/inventory/detail_scenes/simple_detail_popup.tscn")
@export var context_menu_items:Array[ItemContextItem]
@export var max_stacks:int = 1
@export var has_stacks:bool = false
@export var max_durability:int = 1
@export var has_durability:bool = false
@export var column_span:int = 1
@export var row_span:int = 1
@export_multiline var description_text:String
@export_multiline var flavor_text:String
@export var min_pickup_stacks:int = 1
@export var mean_pickup_stacks:int = 1
@export var stack_random_method:GameplayEnums.StackRandomMethod = GameplayEnums.StackRandomMethod.RANDOM
@export var pickup_sound:AudioStream = load("res://game_objects/effects/sounds/foley/generic_pickup_1.ogg")
@export var drop_sound:AudioStream = load("res://game_objects/effects/sounds/foley/generic_pickup_2.ogg")
