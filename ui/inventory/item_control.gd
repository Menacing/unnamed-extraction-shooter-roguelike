extends MarginContainer
class_name ItemControl

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
			_count = get_node("Count")
		return _count

var _name_label:Label
var name_label:Label:
	get:
		if !_name_label:
			_name_label = get_node("Name")
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
			_durability_label = get_node("Durability")
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

var context_items:Array[ItemContextItem]

func _input(event):
	if self.is_visible_in_tree() and event.is_action_pressed("openContextMenu"):
		var cursor_pos = get_global_mouse_position()
		openContextMenu(cursor_pos)
		
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
	EventBus.emit_signal(item.signal_name, self, get_global_mouse_position())


func _on_count_changed(new_count:int):
	count.text = str(new_count)
	
func _on_durability_changed(new_durability:int, max_durability:int):
	durability_label.text = str(new_durability) + "/" + str(max_durability)

func _make_custom_tooltip(for_text):
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.custom_minimum_size = Vector2(400,400)
	label.text = for_text
	return label
	
func _on_menu_close_requested():
	EventBus.context_menu_closed.emit()

