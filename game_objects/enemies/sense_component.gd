extends Node3D
class_name SenseComponent

var _process_delay:float
@export_range(1,60) var tick_rate:int = 20:
	get:
		return tick_rate
	set(value):
		tick_rate = value
		_process_delay = 1.0/float(tick_rate)
var elapsed_time:float = 0.0

@export var view_cone:Area3D
@export_range(0.1,1.0, 0.1) var view_sensitivity = 0.5
@export var listen_area:Area3D
@export var enemy_groups:Array[String]
@export var memory_seconds:float = 10.0

@onready var self_exclusions:Array[RID] = Helpers.get_all_collision_object_3d_recursive(self)

#target information
var sees_enemy:bool = false
var targets:Dictionary[int,TargetInformation] = {}

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > _process_delay:
		elapsed_time = 0.0
		_process_senses()
		
func _process_senses():
	_process_memory()
	_process_look()
	pass


func _process_memory() -> void:
	sees_enemy = false
	
	var targets_to_forget:Array[int]
	for key in targets:
		var target:TargetInformation = targets[key]
		target.currently_has_los = false
		var time_since_last_seen = Time.get_ticks_msec() - target.last_seen_mticks
		if time_since_last_seen > memory_seconds * 1000:
			targets_to_forget.append(key)
	for key in targets_to_forget:
		targets.erase(key)

func _process_look() -> void:
	for viewable_entity in LevelManager.viewable_entities:
		if viewable_entity is PhysicsBody3D:
			if view_cone.overlaps_body(viewable_entity):
				for enemy_group in enemy_groups:
					if viewable_entity.is_in_group(enemy_group):
						var target_exclusions = Helpers.get_all_collision_object_3d_recursive(viewable_entity)
						var los_comp = Helpers.get_component_of_type(viewable_entity, LOSTargetComponent)
						var los_result = false
						if los_comp:
							los_result = Helpers.los_to_point(self,los_comp.los_targets,view_sensitivity, self_exclusions + target_exclusions,true)
						else:
							los_result = Helpers.los_to_point(self,[viewable_entity],view_sensitivity, self_exclusions + target_exclusions,true)
						
						if los_result:
							sees_enemy = los_result
							var target_information = TargetInformation.new()
							target_information.last_known_position = viewable_entity.global_position
							target_information.last_seen_mticks = Time.get_ticks_msec()
							target_information.target = viewable_entity
							target_information.currently_has_los = los_result
							targets[viewable_entity.get_instance_id()] = target_information
				pass
	
	pass


func _on_bullet_detect_radius_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("attack"):
		if body.firer and body.firer is Player:
			if targets[body.firer.get_instance_id()] == null:
				var target_information = TargetInformation.new()
				target_information.last_known_position = body.firer.global_position
				target_information.last_seen_mticks = Time.get_ticks_msec()
				target_information.target = body.firer
				target_information.currently_has_los = false
				targets[body.firer.get_instance_id()] = target_information
			else:
				targets[body.firer.get_instance_id()].last_seen_mticks = Time.get_ticks_msec()
