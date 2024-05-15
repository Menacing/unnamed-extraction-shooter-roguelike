extends Object
class_name ItemInstance

func _init(item_info:ItemInformation) -> void:
	_item_info = item_info.duplicate(true)
	if _item_info.item_internal_inventory:
		_item_info.item_internal_inventory.setup()
		

var id_3d:int
var id_2d:int
var _item_info:ItemInformation
var _stacks: int
var stacks:int:
	get:
		return _stacks
	set(value):
		_stacks = value
		EventBus.item_stack_count_changed.emit(self)
		
var _durability:int = 1
var durability:int:
	get:
		return _durability
	set(value):
		_durability = value
		EventBus.item_durability_changed.emit(self)
var current_inventory_id:int
var is_rotated:bool

func get_show_name() -> bool:
	return _item_info.show_name
	
func get_display_name() -> String:
	return _item_info.display_name
	
func get_item_type() -> GameplayEnums.ItemType:
	return _item_info.item_type

func get_width() -> int:
	if !is_rotated:
		return _item_info.column_span
	else:
		return _item_info.row_span
	
func get_height() -> int:
	if !is_rotated:
		return _item_info.row_span
	else:
		return _item_info.column_span
	
func get_item_type_id() -> String:
	return _item_info.item_type_id

func get_max_allowed_stacks() -> int:
	return _item_info.max_stacks

func get_has_stacks() -> bool:
	return _item_info.has_stacks
	
func get_max_durability() -> int:
	return _item_info.max_durability
	
func get_has_durability() -> bool:
	return _item_info.has_durability

func get_texture() -> Texture:
	if !is_rotated:
		return _item_info.icon
	else:
		return _item_info.icon_r

func get_context_menu_items() -> Array[ItemContextItem]:
	return _item_info.context_menu_items
	
func get_item_description_text() -> String:
	return _item_info.description_text

func get_item_flavor_text() -> String:
	return _item_info.flavor_text

## after you call this you must add the instanced scenes to the scene tree
func spawn_item() -> void:
	if _item_info.has_stacks:
		var stack:int = randi_range(1, _item_info.max_stacks)
		stacks = stack
		
	if _item_info.item_control_scene and id_2d == 0:
		_spawn_item_control()
	if _item_info.item_3d_scene and id_3d == 0:
		_spawn_item_3d()

func get_item_3d() -> Item3D:
	var item_3d:Item3D = instance_from_id(id_3d)
	if item_3d:
		return item_3d
	else:
		return _spawn_item_3d()
	
func get_item_control() -> ItemControl:
	var item_control:ItemControl = instance_from_id(id_2d)
	if item_control:
		return item_control
	else:
		return _spawn_item_control()

func _spawn_item_3d() -> Item3D:
	var item_3d:Item3D = _item_info.item_3d_scene.instantiate()
	self.id_3d = item_3d.get_instance_id()
	item_3d.item_instance_id = self.get_instance_id()
	return item_3d

func _spawn_item_control() -> ItemControl:
	var item_control:ItemControl = _item_info.item_control_scene.instantiate()
	self.id_2d = item_control.get_instance_id()
	item_control.item_instance_id = self.get_instance_id()
	return item_control

func get_item_inventory() -> Inventory:
	return _item_info.item_internal_inventory
	
func get_detail_scene() -> PackedScene:
	return _item_info.detail_scene
