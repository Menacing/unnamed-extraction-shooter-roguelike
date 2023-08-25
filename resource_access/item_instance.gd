extends Object
class_name ItemInstance

func _init(item_info:ItemInformation):
	_item_info = item_info

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
	
func get_item_type() -> ItemInformation.ItemType:
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
	
func get_item_type_id() -> int:
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

#after you call this you must add the instanced scenes to the scene tree
func spawn_item():
	if _item_info.item_control_scene and id_2d == 0:
		var item_control:ItemControl = _item_info.item_control_scene.instantiate()
		self.id_2d = item_control.get_instance_id()
		item_control.item_instance_id = self.get_instance_id()
	if _item_info.item_3d_scene and id_3d == 0:
		var item_3d:Item3D = _item_info.item_3d_scene.instantiate()
		self.id_3d = item_3d.get_instance_id()
		item_3d.item_instance_id = self.get_instance_id()
		
