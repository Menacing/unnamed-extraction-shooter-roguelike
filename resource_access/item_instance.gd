extends Resource
class_name ItemInstance

func _init(item_info:ItemInformation, _item_instance_id = 0) -> void:
	_item_info = item_info.duplicate(true)
	if _item_info.item_internal_inventory:
		_item_info.item_internal_inventory.setup()
	
	if _item_instance_id != 0:
		item_instance_id = _item_instance_id
	else:
		item_instance_id = Helpers.generate_new_id()
	
	ItemAccess.add_item_instance(self)
	
@export var item_instance_id:int
@export var id_3d:int
@export var id_2d:int
@export var _item_info:ItemInformation
@export var _stacks: int = 1
var stacks:int:
	get:
		return _stacks
	set(value):
		_stacks = value
		EventBus.item_stack_count_changed.emit(self)
		
@export var _durability:int = 1
var durability:int:
	get:
		return _durability
	set(value):
		_durability = value
		EventBus.item_durability_changed.emit(self)
@export var current_inventory_id:int
@export var is_rotated:bool
@export var is_equipped:bool

func get_show_name() -> bool:
	return _item_info.show_name
	
func get_display_name() -> String:
	return _item_info.display_name

func get_display_short_name() -> String:
	return _item_info.display_short_name

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
func spawn_item(gen_stacks = true) -> void:
	if _item_info.has_stacks and gen_stacks:
		#Default to fun!
		var stack:int = _item_info.max_stacks
		if _item_info.stack_random_method == GameplayEnums.StackRandomMethod.RANDOM:
			stack = randi_range(_item_info.min_pickup_stacks, _item_info.max_stacks)
		elif _item_info.stack_random_method == GameplayEnums.StackRandomMethod.NORMAL:
			stack = Helpers.get_normalized_random_stack_count(_item_info.min_pickup_stacks,
															  _item_info.mean_pickup_stacks,
															  _item_info.max_stacks)
		else:
			#Someone set an item up with a non specified random method, printing a missable
			#error and keeping the max default for more fun!
			printerr("{unhandled_enum_int} is an invalid integer for the GameplayEnums.StackRandomMethod enum. Defaulting to max stacks.".format({"unhandled_enum_int": _item_info.stack_random_method}))

		stacks = stack
		
	if _item_info.item_control_scene:
		if id_2d == 0 or ItemAccess.get_item_control(id_2d) == null:
			_spawn_item_control()
		
	if _item_info.item_3d_scene:
		if id_3d == 0 or ItemAccess.get_item_3d(id_3d) == null:
			_spawn_item_3d()

func get_item_3d() -> Item3D:
	var item_3d:Item3D = ItemAccess.get_item_3d(id_3d)
	if item_3d:
		return item_3d
	else:
		return _spawn_item_3d()
	
func get_item_control() -> ItemControl:
	var item_control:ItemControl = ItemAccess.get_item_control(id_2d)
	if item_control:
		return item_control
	else:
		return _spawn_item_control()

func _spawn_item_3d() -> Item3D:
	var item_3d:Item3D = _item_info.item_3d_scene.instantiate()
	if self.id_3d != 0:
		item_3d.item_3d_id = self.id_3d
	else:
		item_3d.item_3d_id = Helpers.generate_new_id()
		self.id_3d = item_3d.item_3d_id
	item_3d.item_instance_id = item_instance_id
	return item_3d

func _spawn_item_control() -> ItemControl:
	var item_control:ItemControl = _item_info.item_control_scene.instantiate()
	if self.id_2d != 0:
		item_control.item_control_id = self.id_2d
	else:
		item_control.item_control_id = Helpers.generate_new_id()
		self.id_2d = item_control.item_control_id
	item_control.item_instance_id = item_instance_id
	return item_control

func get_item_inventory() -> Inventory:
	return _item_info.item_internal_inventory
	
func get_detail_scene() -> PackedScene:
	return _item_info.detail_scene
