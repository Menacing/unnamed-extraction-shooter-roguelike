extends Control

@export var drop_location:Node3D

var grabbed_slot_data:SlotData
var external_inventory_owner

@onready var player_inventory: PanelContainer = %PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot
@onready var external_inventory: PanelContainer = %ExternalInventory
##only use for quick transfer
var player_inventory_data:InventoryData
var external_inventory_data:InventoryData

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(_on_toggle_inventory)

func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

func set_player_inventory_data(inventory_data:InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory_data.inventory_context_menu.connect(_on_inventory_context_menu)
	inventory_data.inventory_drop_item.connect(drop_slot_data)
	player_inventory.set_inventory_data(inventory_data)
	player_inventory_data = inventory_data
	
func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory_data.inventory_context_menu.connect(_on_inventory_context_menu)
	inventory_data.inventory_drop_item.connect(drop_slot_data)
	
	external_inventory_data = inventory_data
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()
	
func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		inventory_data.inventory_context_menu.disconnect(_on_inventory_context_menu)
		inventory_data.inventory_drop_item.disconnect(drop_slot_data)
		
		external_inventory_data = null
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

func _on_toggle_inventory(external_inventory_owner = null) -> void:
	self.visible = not self.visible

	if self.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if external_inventory_owner and self.visible:
		set_external_inventory(external_inventory_owner)
	else:
		clear_external_inventory()
		
func on_inventory_interact(inventory_data:InventoryData, index:int, event:InputEvent):
	if event.is_action_pressed("quick_item_transfer"):
		var incoming_slot_data = inventory_data.grab_slot_data(index)
		if incoming_slot_data and player_inventory_data and external_inventory_data:
			if inventory_data == player_inventory_data:
				var result = external_inventory_data.pick_up_slot_data(incoming_slot_data)
				if !result:
					inventory_data.pick_up_slot_data(incoming_slot_data)
			elif inventory_data == external_inventory_data:
				var result = player_inventory_data.pick_up_slot_data(incoming_slot_data)
				if !result:
					inventory_data.pick_up_slot_data(incoming_slot_data)
			pass
		pass
	elif grabbed_slot_data == null and event.is_action_pressed("inv_grab"):
		grabbed_slot_data = inventory_data.grab_slot_data(index)
	elif event.is_action_pressed("inv_grab"):
		grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
	elif grabbed_slot_data == null and event.is_action_pressed("openContextMenu"):
		inventory_data.open_slot_context_menu(index)
	elif grabbed_slot_data and event.is_action_pressed("place_half_of_stack"):
		grabbed_slot_data = inventory_data.drop_half_slot_data(grabbed_slot_data, index)
	elif grabbed_slot_data and event.is_action_pressed("place_single_of_stack"):
		grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	elif event.is_action_pressed("drop_item"):
		var item_to_drop = inventory_data.grab_slot_data(index)
		if item_to_drop:
			drop_slot_data(item_to_drop)
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data, true)
	else:
		grabbed_slot.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_grab") and grabbed_slot_data:
		drop_slot_data(grabbed_slot_data)
		grabbed_slot_data = null
	elif event.is_action_pressed("place_half_of_stack") and grabbed_slot_data:
		drop_slot_data(grabbed_slot_data.create_half_slot_data())
		if grabbed_slot_data.quantity < 1:
			grabbed_slot_data = null
	elif event.is_action_pressed("place_single_of_stack") and grabbed_slot_data:
		drop_slot_data(grabbed_slot_data.create_single_slot_data())
		if grabbed_slot_data.quantity < 1:
			grabbed_slot_data = null
	update_grabbed_slot()

func _input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed("rotate_held_item") and grabbed_slot_data:
		grabbed_slot_data.is_rotated = !grabbed_slot_data.is_rotated
		update_grabbed_slot()
		self.get_viewport().set_input_as_handled()
		

func drop_slot_data(slot_data:SlotData) -> void:
	var item_3d_scene = ItemMappingRepository.get_item_3d(slot_data.item_data.item_type_id)
	if item_3d_scene:
		var item_3d:Item3D = item_3d_scene.instantiate()
		item_3d.slot_data = slot_data
		
		#Add it to the level
		if !LevelManager.add_node_to_level(item_3d):
			get_tree().root.add_child(item_3d)
		
		#move it to the drop point
		item_3d.global_position = drop_location.global_position
	pass

func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
	pass # Replace with function body.


func _on_inventory_context_menu(inventory_data:InventoryData, slot_data:SlotData):
	var menu = PopupMenu.new()
	for item in slot_data.item_data.context_menu_items:
		menu.add_item(item.label)
	#pass
	self.add_child(menu)
	var popup_rect = Rect2i()
	popup_rect.position = Vector2i(get_global_mouse_position())
	menu.id_pressed.connect(inventory_data.handle_context_menu.bind(slot_data.root_index))
	menu.popup(popup_rect)
