@tool
extends Area3D
class_name AreaExtract
	
@onready var extract_timer:Timer = Timer.new()
var extract_cooldown:float = 10.0
var extract_message_template:String = "Extraction in %.3f"

@export var func_godot_properties: Dictionary
@export var target:String
@export var targetname:String

const GREEN_SMOKE_EXTRACT = preload("res://game_objects/props/extract_indicators/green_smoke_extract.tscn")

var extract_marker:Node3D

func _func_godot_apply_properties(entity_properties: Dictionary):
	if 'target' in func_godot_properties and func_godot_properties.target != "":
		self.name = func_godot_properties.target
		self.unique_name_in_owner = true
	if 'targetname' in func_godot_properties:
		targetname = func_godot_properties.targetname
	
	add_to_group("Extract", true)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_child(extract_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)
	extract_timer.timeout.connect(_on_extract_timer_timeout)
	if extract_marker:
		extract_marker.queue_free()
		extract_marker = null
	#_spawn_extract_marker()

func _physics_process(delta: float) -> void:
	if !extract_timer.is_stopped():
		EventBus.update_message.emit(str(get_instance_id()), extract_message_template % extract_timer.time_left)
	pass

func _on_body_entered(body: Node3D):
	if body is Player:
		
		var number_fuel_cores = body.inventory_data.number_items_of_type("fuel_core")
		
		if number_fuel_cores > 0:
			extract_timer.start(extract_cooldown)
			EventBus.create_message.emit(str(get_instance_id()), extract_message_template % extract_cooldown, -1)		
		else:
			EventBus.create_message.emit(str(get_instance_id()), "No Fuel Core! Can't Extract", 5)					
			pass
	pass
func _on_body_exit(body:Node3D):
	if body is Player:
		extract_timer.stop()
		EventBus.remove_message.emit(str(get_instance_id()))		
		

func _on_extract_timer_timeout():
	EventBus.remove_message.emit(str(get_instance_id()))
	
	HideoutManager.current_map_number += 1
	if HideoutManager.has_extracted_enough():
		MenuManager.load_menu(MenuManager.MENU_LEVEL.EXTRACTED)
	else:
		LevelManager.load_hideout_async(true, false)
	pass

var disabled:bool = false
func disable():
	self.monitoring = false
	self.monitorable = false
	self.disabled = true
	extract_marker.queue_free()
	extract_marker = null
	
func enable():
	self.monitoring = true
	self.monitorable = true
	self.disabled = false
	_spawn_extract_marker()
		
func _spawn_extract_marker():
	if extract_marker == null:
		extract_marker = GREEN_SMOKE_EXTRACT.instantiate()
		self.add_child(extract_marker)
		var center_global_pos:Vector3 = Vector3.ZERO
		
		var aabb = Helpers.get_aabb_of_node(self)
		
		center_global_pos.y = self.global_position.y + aabb.position.y + 0.1
		
		var x_begin = aabb.position.x
		var x_end = aabb.end.x
		
		center_global_pos.x = self.global_position.x + lerp(x_begin, x_end, 0.5)
		
		var z_begin = aabb.position.z
		var z_end = aabb.end.z
		
		center_global_pos.z = self.global_position.z + lerp(z_begin, z_end, 0.5)
		
		extract_marker.global_position = center_global_pos
