extends CenterContainer
class_name AmmoSubtypeSelector

var subtype_list_item_scene:PackedScene = preload("res://ui/misc/sub_type_list_item.tscn")

@onready var ammo_menu = $MarginContainer/VBoxContainer

var _selecting:bool = false
var selected_index:int = 0

func start_selection(request:AmmoSubtypeSelectionRequest):
	if !_selecting:
		_selecting = true
		self.visible = true
		
		var current_list_item:AmmoSubTypeListItem = null
		
		for assri:AmmoSubtypeSelectionRequestItem in request.subtypes:
			var list_item:AmmoSubTypeListItem = subtype_list_item_scene.instantiate()
			list_item._ammo_type = request.type
			list_item._ammo_subtype = assri.subtype
			list_item.current_amount = assri.current_amount
			ammo_menu.add_child(list_item)
			if current_list_item == null:
				current_list_item = list_item
			
		current_list_item.select()
		
func end_selection():
	_selecting = false
	self.visible = false
	Helpers.queue_free_children(ammo_menu)

func _input(event):
	if _selecting and event.is_action_pressed("change_ammo_subtype"):
		var current_item:AmmoSubTypeListItem = ammo_menu.get_child(selected_index)
		current_item.deselect()
		
		selected_index = (selected_index + 1) % ammo_menu.get_child_count()
		
		var next_item:AmmoSubTypeListItem = ammo_menu.get_child(selected_index)
		next_item.select()
		accept_event()
		

class AmmoSubtypeSelectionRequestItem:
	var subtype:AmmoSubtype
	var current_amount:int
	
class AmmoSubtypeSelectionRequest:
	var type:AmmoType
	var subtypes:Array[AmmoSubtypeSelectionRequestItem]
