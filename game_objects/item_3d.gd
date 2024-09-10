extends RigidBody3D
class_name Item3D

@export var slot_data:SlotData:
	get:
		return slot_data
	set(value):
		slot_data = value
		if slot_data and slot_data.internal_inventory:
			slot_data.internal_inventory.item_equipment_changed.connect(_on_item_equipment_changed)

static func instantiate_from_slot_data(slot_data:SlotData) -> Item3D:
	var item_3d_scene = ItemMappingRepository.get_item_3d(slot_data.item_data.item_type_id)
	if item_3d_scene:
		var item_3d:Item3D = item_3d_scene.instantiate()
		item_3d.slot_data = slot_data
		item_3d.set_additional_slot_data(slot_data)
		return item_3d
	else:
		return null

func set_additional_slot_data(slot_data:SlotData) -> void:
	pass

## string id of the item. Must match the id in the corresponding ItemInformation resources
@export var item_type_id:String
@export var world_collider_path:NodePath
@export var longest_side_size:float = 1.0
@export var model_node:Node3D
var _world_collider:CollisionShape3D
var world_collider:CollisionShape3D:
	get:
		if _world_collider:
			return _world_collider
		else:
			_world_collider =  get_node(world_collider_path)
			return _world_collider
@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@export var start_highlighted:bool = true
@export var meshes_to_fade_on_pickup:Array[MeshInstance3D] = []
var _prox_fade_mats:Array[StandardMaterial3D] = []
var is_picked_up:bool = false

func _ready() -> void:
	assert(world_collider_path != null)
	if start_highlighted:
		Helpers.apply_material_overlay_to_children(self,item_highlight_m)
	else:
		Helpers.apply_material_overlay_to_children(self,null)
	
	var _base_materials:Array[StandardMaterial3D] = []

	for mesh_inst:MeshInstance3D in meshes_to_fade_on_pickup:
		var number_surfaces = mesh_inst.mesh.get_surface_count()
		for i in range(number_surfaces):
			_base_materials.append(mesh_inst.mesh.surface_get_material(i))
	for mat:BaseMaterial3D in _base_materials:
		var new_mat:BaseMaterial3D = mat.duplicate()
		new_mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
		new_mat.distance_fade_min_distance = 0.0
		new_mat.distance_fade_max_distance = 2.0
		_prox_fade_mats.append(new_mat)
	EventBus.game_saving.connect(_on_game_saving)
	EventBus.before_game_loading.connect(_on_game_before_loading)
	
	if !slot_data:
		slot_data = SlotData.instantiate_from_item_information(ItemMappingRepository.get_item_information(item_type_id))

func pick_up_item(inventory_data:InventoryData) -> bool:
	if inventory_data.pick_up_slot_data(slot_data):
		#TODO: We probably don't want to queue free here for real
		queue_free()
		return true
	return false

func dropped() -> void:
	world_collider.disabled = false
	self.freeze = false
	self.visible = true
	Helpers.apply_material_overlay_to_children(self,item_highlight_m)
	self.apply_torque_impulse(Vector3.FORWARD)
	for mesh_inst:MeshInstance3D in meshes_to_fade_on_pickup:
		var number_surfaces:int = mesh_inst.mesh.get_surface_count()
		for i in range(number_surfaces):
			mesh_inst.set_surface_override_material(i,null)
	
	is_picked_up = false

func picked_up(actor_id:int = 0) -> void:
	self.transform = Transform3D.IDENTITY
#	self.gravity_scale = 0
	world_collider.disabled = true
	self.freeze = true
	Helpers.apply_material_overlay_to_children(self,null)

	var mat_index:int = 0
	for mesh_inst:MeshInstance3D in meshes_to_fade_on_pickup:
		var number_surfaces:int = mesh_inst.mesh.get_surface_count()
		for i in range(number_surfaces):
			mesh_inst.set_surface_override_material(i, _prox_fade_mats[mat_index])
				
	is_picked_up = true
	
func destroy() -> void:
	self.queue_free()

func copy_model() -> Node3D:
	return model_node.duplicate()

func _on_game_saving(save_file:SaveFile):
	#only save the data if not picked up
	if save_file and !is_picked_up:
		var item_data:TopLevelEntitySaveData = TopLevelEntitySaveData.new()
		item_data.global_transform = self.global_transform
		item_data.scene_path = self.scene_file_path
		#item_data.additional_data["item_instance_id"] = item_instance_id
		#item_data.additional_data["item_3d_id"] = item_3d_id
		save_file.top_level_entity_save_data.append(item_data)

func _on_game_before_loading():
	self.queue_free()
	
func _on_load_game(save_data:TopLevelEntitySaveData):
	if save_data:
		self.global_transform = save_data.global_transform
		#item_instance_id = save_data.additional_data["item_instance_id"]
		#item_3d_id = save_data.additional_data["item_3d_id"]

func _on_item_equipment_changed(inventory_data:InventoryData, equipment_slot:EquipmentSlot):
	pass
