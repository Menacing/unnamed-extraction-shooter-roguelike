extends Control
class_name InventoryInterface

@export var drop_location:Node3D
@export var ammo_component:AmmoComponent

var grabbed_slot_data:SlotData
var external_inventory_owner

@onready var player_inventory: PanelContainer = %ITEMS
@onready var grabbed_slot: ItemSlotControl = $GrabbedSlot
@onready var external_inventory: PanelContainer = %ExternalInventory
@onready var hideout_menu: HideoutMenu = %HideoutMenu
@onready var item_detail_container: PanelContainer = %ItemDetailContainer

##only use for quick transfer
var player_inventory_data:InventoryData
var external_inventory_data:InventoryData
@onready var foley_audio_stream_player_3d: AudioStreamPlayer3D = $FoleyAudioStreamPlayer3D

func _ready() -> void:
	EventBus.level_loaded.connect(_connect_external_inventories)
	_connect_external_inventories()

func _connect_external_inventories() -> void:
	var all_nodes =  get_tree().get_nodes_in_group("external_inventory")
	for node in all_nodes:
		if !node.toggle_inventory.is_connected(_on_toggle_inventory):
			node.toggle_inventory.connect(_on_toggle_inventory)

func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

func _connect_inventory_data_signals(inventory_data:InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory_data.inventory_equipment_slot_interact.connect(on_inventory_equipment_slot_interact)
	inventory_data.inventory_context_menu.connect(_on_inventory_context_menu)
	inventory_data.inventory_equipment_slot_context_menu.connect(_on_inventory_equipment_slot_context_menu)
	inventory_data.inventory_drop_item.connect(drop_slot_data)
	inventory_data.item_show_detail_scene.connect(_on_item_show_detail_scene)
	
func _disconnect_inventory_data_signals(inventory_data:InventoryData) -> void:
	inventory_data.inventory_interact.disconnect(on_inventory_interact)
	inventory_data.inventory_equipment_slot_interact.disconnect(on_inventory_equipment_slot_interact)
	inventory_data.inventory_context_menu.disconnect(_on_inventory_context_menu)
	inventory_data.inventory_equipment_slot_context_menu.disconnect(_on_inventory_equipment_slot_context_menu)
	inventory_data.inventory_drop_item.disconnect(drop_slot_data)
	inventory_data.item_show_detail_scene.disconnect(_on_item_show_detail_scene)

func set_player_inventory_data(inventory_data:InventoryData) -> void:
	_connect_inventory_data_signals(inventory_data)
	inventory_data.ammo_picked_up.connect(_on_ammo_picked_up)
	player_inventory.set_inventory_data(inventory_data)
	player_inventory_data = inventory_data
	
func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	_connect_inventory_data_signals(inventory_data)
	
	external_inventory_data = inventory_data
	external_inventory.set_inventory_data(inventory_data)
	external_inventory.show()
	
func set_hideout_inventory() -> void:
	external_inventory_owner = HideoutManager
	var inventory_data = external_inventory_owner.inventory_data
	
	_connect_inventory_data_signals(inventory_data)
	inventory_data.material_picked_up.connect(_on_material_picked_up)
	
	external_inventory_data = inventory_data
	hideout_menu.stash_inventory_control.set_inventory_data(inventory_data)
	hideout_menu.show()
	
func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		_disconnect_inventory_data_signals(inventory_data)
		if !HideoutManager.in_hideout:
			external_inventory_data = null
			external_inventory.clear_inventory_data(inventory_data)
			external_inventory.hide()
			external_inventory_owner = null
		else:
			external_inventory_data = null
			hideout_menu.stash_inventory_control.clear_inventory_data(inventory_data)
			hideout_menu.hide()
			external_inventory_owner = null
	if item_detail_container.visible:
		for child in item_detail_container.get_children():
			child.queue_free()
		item_detail_container.hide()

func _on_toggle_inventory(external_inventory_owner = null) -> void:
	self.visible = not self.visible

	if self.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if self.visible and HideoutManager.in_hideout:
		set_hideout_inventory()
	elif external_inventory_owner and self.visible:
		set_external_inventory(external_inventory_owner)
	else:
		clear_external_inventory()
		
func on_inventory_interact(inventory_data:InventoryData, index:int, event:InputEvent):
	if event.is_action_pressed("quick_item_transfer"):
		var incoming_slot_data = inventory_data.grab_slot_data(index)
		if incoming_slot_data:
			play_pickup_sound(incoming_slot_data)
			if incoming_slot_data and player_inventory_data and external_inventory_data:
				if inventory_data == player_inventory_data:
					var result = external_inventory_data.pick_up_slot_data(incoming_slot_data)
					if !result:
						inventory_data.pick_up_slot_data(incoming_slot_data)
				elif inventory_data == external_inventory_data:
					var result = player_inventory_data.pick_up_slot_data(incoming_slot_data)
					if !result:
						inventory_data.pick_up_slot_data(incoming_slot_data)
			else:
				inventory_data.pick_up_slot_data(incoming_slot_data)
			pass
	elif grabbed_slot_data == null and event.is_action_pressed("inv_grab"):
		grabbed_slot_data = inventory_data.grab_slot_data(index)
		play_pickup_sound(grabbed_slot_data)
	elif event.is_action_pressed("inv_grab"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
	elif grabbed_slot_data == null and event.is_action_pressed("openContextMenu"):
		inventory_data.open_slot_context_menu(index)
	elif grabbed_slot_data and event.is_action_pressed("place_half_of_stack"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_half_slot_data(grabbed_slot_data, index)
	elif grabbed_slot_data and event.is_action_pressed("place_single_of_stack"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	elif event.is_action_pressed("drop_item"):
		var item_to_drop = inventory_data.grab_slot_data(index)
		if item_to_drop:
			drop_slot_data(item_to_drop)
	update_grabbed_slot()

func on_inventory_equipment_slot_interact(inventory_data:InventoryData, slot_name:String, event:InputEvent) -> void:
	if event.is_action_pressed("quick_item_transfer"):
		var incoming_slot_data = inventory_data.grab_equipment_slot_data(slot_name)
		if incoming_slot_data:
			play_pickup_sound(incoming_slot_data)
			if incoming_slot_data and player_inventory_data and external_inventory_data:
				if inventory_data == player_inventory_data:
					var result = external_inventory_data.pick_up_slot_data(incoming_slot_data)
					if !result:
						inventory_data.pick_up_slot_data(incoming_slot_data)
				elif inventory_data == external_inventory_data:
					var result = player_inventory_data.pick_up_slot_data(incoming_slot_data)
					if !result:
						inventory_data.pick_up_slot_data(incoming_slot_data)
			else:
				inventory_data.pick_up_slot_data(incoming_slot_data)
			pass
	elif grabbed_slot_data == null and event.is_action_pressed("inv_grab"):
		grabbed_slot_data = inventory_data.grab_equipment_slot_data(slot_name)
		play_pickup_sound(grabbed_slot_data)
	elif event.is_action_pressed("inv_grab"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_equipment_slot_data(grabbed_slot_data, slot_name)
	elif grabbed_slot_data == null and event.is_action_pressed("openContextMenu"):
		inventory_data.open_equipment_slot_context_menu(slot_name)
	elif grabbed_slot_data and event.is_action_pressed("place_half_of_stack"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_half_slot_data_equipment_slot(grabbed_slot_data, slot_name)
	elif grabbed_slot_data and event.is_action_pressed("place_single_of_stack"):
		play_drop_sound(grabbed_slot_data)
		grabbed_slot_data = inventory_data.drop_single_slot_data_equipment_slot(grabbed_slot_data, slot_name)
	elif event.is_action_pressed("drop_item"):
		var item_to_drop = inventory_data.grab_equipment_slot_data(slot_name)
		if item_to_drop:
			drop_slot_data(item_to_drop)
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data, true)
	else:
		grabbed_slot.hide()

##Didn't click a slot so you must be trying to drop something
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
	var item_3d:Item3D = Item3D.instantiate_from_slot_data(slot_data)
	
	if item_3d:
		play_drop_sound(slot_data)
		#Add it to the level
		if !LevelManager.add_node_to_level(item_3d):
			get_tree().root.add_child(item_3d)
		#move it to the drop point
		item_3d.global_position = drop_location.global_position

func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()

func _on_inventory_context_menu(inventory_data:InventoryData, slot_data:SlotData) -> void:
	var menu = PopupMenu.new()
	for item in slot_data.item_data.context_menu_items:
		menu.add_item(item.label)
	#pass
	self.add_child(menu)
	var popup_rect = Rect2i()
	popup_rect.position = Vector2i(get_global_mouse_position())
	menu.id_pressed.connect(inventory_data.handle_context_menu.bind(slot_data.root_index))
	menu.popup(popup_rect)
	
func _on_inventory_equipment_slot_context_menu(inventory_data:InventoryData, equipment_slot:EquipmentSlot) -> void:
	var menu = PopupMenu.new()
	for item in equipment_slot.slot_data.item_data.context_menu_items:
		menu.add_item(item.label)
	#pass
	self.add_child(menu)
	var popup_rect = Rect2i()
	popup_rect.position = Vector2i(get_global_mouse_position())
	menu.id_pressed.connect(inventory_data.handle_equipment_slot_context_menu.bind(equipment_slot.slot_name))
	menu.popup(popup_rect)

func _on_item_show_detail_scene(slot_data:SlotData, detail_scene:ItemDetailPopup) -> void:
	for child in item_detail_container.get_children():
		child.queue_free()
	item_detail_container.add_child(detail_scene)
	item_detail_container.show()
	detail_scene.parent_inventory_interface = self
	if (slot_data):
		detail_scene.set_slot_data(slot_data)
		pass
	pass

func _on_ammo_picked_up(inventory_data:InventoryData, slot_data:SlotData) -> void:
	var ammo_information:AmmoInformation = slot_data.item_data
	var remainder = ammo_component.add_ammo(ammo_information.ammo_type.name, ammo_information.ammo_subtype.name, slot_data.quantity)
	play_pickup_sound(slot_data)
	slot_data.quantity = remainder
	if remainder == 0:
		inventory_data.set_slot_data_by_index(slot_data.root_index, null, slot_data.get_height(), slot_data.get_width())
		
func _on_material_picked_up(inventory_data:InventoryData, slot_data:SlotData) -> void:
	var remainder = HideoutManager.add_crafting_material(slot_data)
	play_pickup_sound(slot_data)
	slot_data.quantity = remainder
	if remainder == 0:
		inventory_data.set_slot_data_by_index(slot_data.root_index, null, slot_data.get_height(), slot_data.get_width())

func play_drop_sound(slot_data:SlotData):
	if slot_data:
		foley_audio_stream_player_3d.stream = slot_data.item_data.drop_sound
		foley_audio_stream_player_3d.play()
	pass
	
func play_pickup_sound(slot_data:SlotData):
	if slot_data:
		foley_audio_stream_player_3d.stream = slot_data.item_data.pickup_sound
		foley_audio_stream_player_3d.play()
	pass

func _on_player_toggle_stash() -> void:
	hideout_menu.show_stash_tab()

func _on_player_toggle_map_select() -> void:
	hideout_menu.show_map_select_tab()
