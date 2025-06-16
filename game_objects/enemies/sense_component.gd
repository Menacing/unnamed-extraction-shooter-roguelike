extends Node3D
class_name SenseComponent

var _process_delay:float = 0.05
@export_range(1,60) var tick_rate:int = 20
var elapsed_time:float = 0.0

@export var view_distance:float = 100.0
@export var fov_angle:float = 90.0
@export_range(0.1,1.0, 0.1) var view_sensitivity = 0.5
@export var listen_area:Area3D
@export var enemy_groups:Array[String]
@export var memory_seconds:float = 10.0
@export var friend_groups:Array[String]


@export var self_to_exclude:Node3D

#target information
var sees_enemy:bool = false
var targets:Dictionary[int,TargetInformation] = {}
var shots_taken:Array[int] = []

func _ready() -> void:
	_process_delay = (1.0 / float(tick_rate)) + randf_range(-0.1, 0.1)
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
	var now = Time.get_ticks_msec()
	var memory_ms = memory_seconds * 1000
	var targets_to_forget:Array[int]
	for key in targets:
		var target:TargetInformation = targets[key]
		target.currently_has_los = false
		var time_since_last_seen = now - target.last_seen_mticks
		if time_since_last_seen > memory_ms:
			targets_to_forget.append(key)
	for key in targets_to_forget:
		targets.erase(key)
		
	while shots_taken.size() > 0 and now - shots_taken[0] > memory_ms:
		shots_taken.pop_front()
		

func _process_look() -> void:
	for viewable_entity in LevelManager.viewable_entities:
		if viewable_entity is PhysicsBody3D:
			for enemy_group in enemy_groups:
				if viewable_entity.is_in_group(enemy_group) and viewable_entity.self_exclusions:
					
					#if in view distance
					var entity_pos:Vector3 = viewable_entity.global_position
					var to_entity:Vector3 = entity_pos - self.global_position
					var dist:float = to_entity.length()
					if dist < view_distance:
						
						#and inside fov angle
						var to_entity_dir:Vector3 = to_entity.normalized()
						var forward_dir:Vector3 = get_parent().global_transform.basis.z
						var in_cone:bool = false
						
						var angle_between = rad_to_deg(forward_dir.angle_to(to_entity_dir))
						
						in_cone = angle_between <= fov_angle
						
						if in_cone:
							#and has line of sight
							var target_exclusions = viewable_entity.self_exclusions
							var los_comp = Helpers.get_component_of_type(viewable_entity, LOSTargetComponent)
							var los_result = false
							if los_comp:
								los_result = Helpers.los_to_point(self,los_comp.los_targets,view_sensitivity, self_to_exclude.self_exclusions + target_exclusions,true)
							else:
								los_result = Helpers.los_to_point(self,[viewable_entity],view_sensitivity, self_to_exclude.self_exclusions + target_exclusions,true)
							
							if los_result:
								sees_enemy = los_result
								var target_information = TargetInformation.new()
								target_information.last_known_position = viewable_entity.global_position
								target_information.last_seen_mticks = Time.get_ticks_msec()
								target_information.target = viewable_entity
								target_information.currently_has_los = los_result
								targets[viewable_entity.get_instance_id()] = target_information

	pass

func _on_bullet_detect_radius_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("attack"):
		if body.firer and body.firer is Player:
			shots_taken.append(Time.get_ticks_msec())
			if targets[body.firer.get_instance_id()] == null:
				var target_information = TargetInformation.new()
				target_information.last_known_position = body.firer.global_position
				target_information.last_seen_mticks = Time.get_ticks_msec()
				target_information.target = body.firer
				target_information.currently_has_los = false
				targets[body.firer.get_instance_id()] = target_information
			else:
				targets[body.firer.get_instance_id()].last_seen_mticks = Time.get_ticks_msec()

func _on_bullet_detect_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("attack"):
		if body.firer and body.firer is Player:
			shots_taken.append(Time.get_ticks_msec())
			if !targets.has(body.firer.get_instance_id()) or targets[body.firer.get_instance_id()] == null:
				var target_information = TargetInformation.new()
				target_information.last_known_position = body.firer.global_position
				target_information.last_seen_mticks = Time.get_ticks_msec()
				target_information.target = body.firer
				target_information.currently_has_los = false
				targets[body.firer.get_instance_id()] = target_information
			else:
				targets[body.firer.get_instance_id()].last_seen_mticks = Time.get_ticks_msec()

func get_last_known_locations() -> Array[Vector3]:
	var returnable:Array[Vector3] = []
	for key in targets.keys():
		returnable.append(targets[key].last_known_position)
		
	return returnable
		
