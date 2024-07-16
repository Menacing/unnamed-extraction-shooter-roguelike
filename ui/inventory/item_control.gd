extends MarginContainer
class_name ItemControl

var stack_splitter_popup_scene = preload("res://ui/inventory/stack_splitter.tscn")

var item_control_id:int:
	get:
		return item_control_id
	set(value):
		item_control_id = value
		ItemAccess.add_item_control(self)

var item_instance_id:int
func get_item_instance() -> ItemInstance:
	return InventoryManager.get_item(item_instance_id)

func _ready():
	
	if item_control_id == 0:
		item_control_id = Helpers.generate_new_id()
	
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.item_stack_count_changed.connect(_on_item_stack_count_changed)
	EventBus.context_menus_drop_item.connect(_on_context_menus_drop_item)
	EventBus.context_menus_split_stack.connect(_on_context_menus_split_stack)
	EventBus.context_menus_open_item_detail.connect(_on_context_menus_open_item_detail)
	show_durability = get_item_instance().get_has_durability()
	show_count = get_item_instance().get_has_stacks()
	name_label.text = get_item_instance().get_display_short_name()
	show_name = get_item_instance().get_show_name()
	tooltip_text = get_item_instance().get_display_name()

	var item_inventory = get_item_instance().get_item_inventory()
	if item_inventory:
		_has_inventory = true
		_item_inventory_id = item_inventory.inventory_id
	
	update_dimensions()

func _on_item_picked_up(result:InventoryInsertResult):
	if result.item_instance_id == item_instance_id:
		_orig_is_rotated = _is_rotated
		update_dimensions()

func _on_item_stack_count_changed(item_inst:ItemInstance):
	if !is_queued_for_deletion() and item_instance_id == item_inst.item_instance_id:
		stacks = item_inst.stacks
		
func _on_item_durability_count_changed(item_inst:ItemInstance):
	if !is_queued_for_deletion() and item_instance_id == item_inst.item_instance_id:
		durability = item_inst.durability

func update_dimensions():
	var cell_size = Helpers.get_cell_size()
	self.size.x = get_item_instance().get_width() * cell_size
	self.size.y = get_item_instance().get_height() * cell_size
	item_texture_rect.texture = get_item_instance().get_texture()
		

var _orig_is_rotated:bool
var _is_rotated:bool:
	get:
		if get_item_instance():
			return get_item_instance().is_rotated
		else:
			return false
	set(value):
		if get_item_instance():
			get_item_instance().is_rotated = value

var _item_texture_rect:TextureRect
var item_texture_rect:TextureRect:
	get:
		if !_item_texture_rect:
			_item_texture_rect = get_node("ItemTexture")
		return _item_texture_rect

var _stacks:int = 0
var stacks:int:
	get:
		return _stacks
	set(value):
		_stacks = value
		_on_count_changed(_stacks)
		
var _count:Label
var count:Label:
	get:
		if !_count:
			_count = get_node("%Count")
		return _count

var _name_label:Label
var name_label:Label:
	get:
		if !_name_label:
			_name_label = get_node("%Name")
		return _name_label
		
var _show_name:bool
var show_name:bool = false:
	get:
		return _show_name
	set(value):
		_show_name = value
		name_label.visible = _show_name
		
var _show_count:bool
var show_count:bool = false:
	get:
		return _show_count
	set(value):
		_show_count = value
		count.visible = _show_count
		
var _durability_label:Label
var durability_label:Label:
	get:
		if !_durability_label:
			_durability_label = get_node("%Durability")
		return _durability_label
		
var _show_durability:bool
var show_durability:bool = false:
	get:
		return _show_durability
	set(value):
		_show_durability = value
		durability_label.visible = _show_durability
		
var _durability:int = 0
var durability:int:
	get:
		return _durability
	set(value):
		_durability = value
		_on_durability_changed(_durability, max_durability)
		
var _max_durability:int = 0
var max_durability:int:
	get:
		return _max_durability
	set(value):
		_max_durability = value
		_on_durability_changed(durability, _max_durability)

var context_items:Array[ItemContextItem]:
	get:
		return get_item_instance().get_context_menu_items()
	
var _is_dragging:bool

var _has_inventory:bool = false
var _item_inventory_id:int
	
func _input(event:InputEvent):
	if _is_dragging:
		if event.is_action_pressed("rotate_held_item"):
			toggle_rotation()
			accept_event()
			
		if event.is_action_pressed("place_half_of_stack") and stacks > 0:
			# Detect control under mouse
			var control: Control = Helpers.get_control_in_group_with_method_at_position(event.global_position, "droppable_inventory_controls", "_can_drop_data")
			
			# If control exists and has _can_drop_data function, call it
			if control:
				var drop_data = get_viewport().gui_get_drag_data()
				var orig_number_to_drop:int = drop_data["number_to_drop"]
				var local_pos = event.global_position - control.global_position
				@warning_ignore("integer_division")
				drop_data["number_to_drop"] = round(orig_number_to_drop/2)
				if control._can_drop_data(local_pos, drop_data):
					control._drop_data(local_pos, drop_data)
					if get_item_instance() and !is_queued_for_deletion():
						force_drag(create_drag_data_data(), _create_drag_control())
					
			accept_event()
		elif event.is_action_pressed("place_single_of_stack") and stacks > 0:
			# Detect control under mouse
			var control: Control = Helpers.get_control_in_group_with_method_at_position(event.global_position, "droppable_inventory_controls", "_can_drop_data")
			
			# If control exists and has _can_drop_data function, call it
			if control:
				var drop_data = get_viewport().gui_get_drag_data()
				var _orig_number_to_drop:int = drop_data["number_to_drop"]
				var local_pos = event.global_position - control.global_position
				drop_data["number_to_drop"] = 1
				if control._can_drop_data(local_pos, drop_data):
					control._drop_data(local_pos, drop_data)
					if get_item_instance() and !is_queued_for_deletion():
						force_drag(create_drag_data_data(), _create_drag_control())
					
			accept_event()
			


func _gui_input(event:InputEvent):
	if self.is_visible_in_tree(): 
		if event.is_action_pressed("openContextMenu"):
			accept_event()
			var cursor_pos = get_global_mouse_position()
			openContextMenu(cursor_pos)
		elif event.is_action_pressed("drop_item"):
			accept_event()
			var item_instance:ItemInstance = get_item_instance()
			if item_instance:
				var original_inventory_id = item_instance.current_inventory_id
				InventoryManager.remove_item(item_instance_id, original_inventory_id)
				EventBus.drop_item.emit(item_instance, original_inventory_id)
		elif event.is_action_pressed("quick_item_transfer"):
			accept_event()
			EventBus.item_control_quick_transfer.emit(self)
		elif event is InputEventMouseButton:
			if event.double_click:
				print_stack()
				_on_context_menus_open_item_detail(get_item_instance(), Vector2())
		
func openContextMenu(pos:Vector2):
	var menu = PopupMenu.new()
	for item in context_items:
		menu.add_item(item.label)
	pass
	self.add_child(menu)
	var popup_rect = Rect2i()
	popup_rect.position = Vector2i(pos)
	menu.id_pressed.connect(_on_context_menu_pressed)
	menu.close_requested.connect(_on_menu_close_requested)
	menu.popup_hide.connect(_on_menu_close_requested)
	menu.popup(popup_rect)
	EventBus.context_menu_opened.emit()
	
func _on_context_menu_pressed(id:int):
	var item = context_items[id]
	EventBus.emit_signal(item.signal_name, get_item_instance(), get_global_mouse_position())

func _on_context_menus_drop_item(item_inst:ItemInstance, _cursor_pos:Vector2):
	if item_inst and item_inst.item_instance_id == item_instance_id:
		var original_inventory_id = item_inst.current_inventory_id
		InventoryManager.remove_item(item_instance_id, original_inventory_id)
		EventBus.drop_item.emit(item_inst, original_inventory_id)

func _on_context_menus_split_stack(item_inst:ItemInstance, _cursor_pos:Vector2):
	if item_inst and item_inst.item_instance_id == item_instance_id:
		var stack_splitter_popup:StackSplitter = stack_splitter_popup_scene.instantiate()
		stack_splitter_popup.item_instance_id = item_instance_id
		self.get_parent().add_child(stack_splitter_popup)
		stack_splitter_popup.top_level = true
		stack_splitter_popup.position = _cursor_pos 
		
func _on_context_menus_open_item_detail(item_inst:ItemInstance, _cursor_pos:Vector2):
	if item_inst and item_inst.item_instance_id == item_instance_id:
		var item_detail_popup:ItemDetailPopup = item_inst.get_detail_scene().instantiate()
		item_detail_popup.item_instance_id = item_instance_id
		var internal_inventory = item_inst.get_item_inventory()
		if (internal_inventory):
			item_detail_popup.set_internal_inventory(internal_inventory)
		self.get_parent().add_child(item_detail_popup)
		#item_detail_popup.top_level = true
		#item_detail_popup.z_index = 2

func _on_count_changed(new_count:int):
	count.text = str(new_count)
	
func _on_durability_changed(new_durability:int, new_max_durability:int):
	durability_label.text = str(new_durability) + "/" + str(new_max_durability)

	
func _on_menu_close_requested():
	EventBus.context_menu_closed.emit()

func toggle_rotation():
	_is_rotated = !_is_rotated
	set_drag_preview(_create_drag_control())

func _create_drag_control() -> Control:
	var drag_texture = TextureRect.new()
	drag_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var cell_size = Helpers.get_cell_size()

	drag_texture.size.x = get_item_instance().get_width() * cell_size
	drag_texture.size.y = get_item_instance().get_height() * cell_size
	drag_texture.texture = get_item_instance().get_texture()
	
	var drag_control = Control.new()
	drag_control.size = self.size
	drag_control.add_child(drag_texture)
	@warning_ignore("integer_division")
	drag_texture.position = Vector2(-cell_size/2,-cell_size/2)
	drag_control.z_index = self.z_index + 1
	drag_control.modulate = Color(Color.WHITE, .5)
	return drag_control

func create_drag_data_data():
	var data = {}
	data["item_instance_id"] = item_instance_id
	var item_inst:ItemInstance = get_item_instance()
	if item_inst.get_has_stacks():
		data["number_to_drop"] = item_inst.stacks
	if item_inst.get_item_type() == GameplayEnums.ItemType.BACKPACK and item_inst.is_equipped:
		data["is_equipped_backpack"] = true
	return data

func _get_drag_data(_position):
	set_drag_preview(_create_drag_control())
	_is_dragging = true
	_orig_is_rotated = _is_rotated
	return create_drag_data_data()

func _notification(what):
	if what == Node.NOTIFICATION_DRAG_END:
		_is_dragging = false
		_is_rotated = _orig_is_rotated
		
func _can_drop_data(_at_position, data) -> bool:
	if _has_inventory:
		var item_instance_id:int = data["item_instance_id"]
		var target_inventory_id = _item_inventory_id
		return InventoryManager.can_place_item_in_inventory(item_instance_id, target_inventory_id)
	else:
		return false

func _drop_data(_at_position, data):
	if _has_inventory:
		var item_instance_id:int = data["item_instance_id"]
		var target_inventory_id = _item_inventory_id
		InventoryManager.place_item_in_inventory(item_instance_id, target_inventory_id)
		return 
	else:
		return
