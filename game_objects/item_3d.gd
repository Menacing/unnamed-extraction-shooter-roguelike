extends RigidBody3D
class_name Item3D

var _actor_id:int = 0
var item_instance_id:int
func get_item_instance() -> ItemInstance:
	if item_instance_id == 0:
		spawn_item()
	return InventoryManager.get_item(item_instance_id)
			
var internal_inventory_id:int
## string id of the item. Must match the id in the corresponding ItemInformation resources
@export var item_type_id:String
@export var world_collider_path:NodePath
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

func _ready() -> void:
	assert(world_collider_path != null)
	if start_highlighted:
		Helpers.apply_material_overlay_to_children(self,item_highlight_m)
	else:
		Helpers.apply_material_overlay_to_children(self,null)
	
	var item_instance := get_item_instance()
	if item_instance:
		var item_internal_inventory := item_instance.get_item_inventory()
		if item_internal_inventory:
			internal_inventory_id = item_internal_inventory.get_instance_id()
			EventBus.item_picked_up.connect(_on_item_picked_up)
			EventBus.item_removed_from_slot.connect(_on_item_removed_from_slot)

func dropped() -> void:
	world_collider.disabled = false
	self.freeze = false
	self.visible = true
	Helpers.apply_material_overlay_to_children(self,item_highlight_m)
	self.apply_torque_impulse(Vector3.FORWARD)
	_actor_id = 0
	

func picked_up(actor_id:int = 0) -> void:
	self.transform = Transform3D.IDENTITY
#	self.gravity_scale = 0
	world_collider.disabled = true
	self.freeze = true
	Helpers.apply_material_overlay_to_children(self,null)
	_actor_id = actor_id

	
func destroy() -> void:
	#Events.item_destroyed.emit(self)
	self.call_deferred("queue_free")

func set_stacks(amount:int) -> void:
	get_item_instance().stacks = amount
	
func spawn_item() -> void:
	pass
	InventoryManager.spawn_from_item3d(self)

func _on_item_picked_up(result:InventoryInsertResult) -> void:
	if result.inventory_id == internal_inventory_id:
		var item_instance:ItemInstance = InventoryManager.get_item(result.item_instance_id)
		var item_3d:Item3D = instance_from_id(item_instance.id_3d)
		Helpers.force_parent(item_3d,self)
		item_3d.picked_up()
		if result.location.location == InventoryLocationResult.LocationType.SLOT:
			pass
		elif result.location.location == InventoryLocationResult.LocationType.GRID:
			item_3d.visible = false
			
func _on_item_removed_from_slot(_item_inst:ItemInstance, _inventory_id:int, _slot_name:String) -> void:
	pass
