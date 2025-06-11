extends Marker3D

@export var enemy:Enemy

func _physics_process(delta: float) -> void:
	if _fire_suppressed_event:
		fire_suppressed_event()
		_fire_suppressed_event = false
		
var _fire_suppressed_event = false

func fire_suppressed_event():
	if enemy:
		var target_information = TargetInformation.new()
		target_information.last_known_position = self.global_position
		target_information.last_seen_mticks = Time.get_ticks_msec()
		target_information.target = self
		target_information.currently_has_los = true
		enemy.sensory_component.targets[self.get_instance_id()] = target_information

		print("In physics tick: ", Engine.is_in_physics_frame())
		enemy.state_chart.send_event("Suppressed")

func _on_timer_timeout() -> void:
	_fire_suppressed_event = true
	pass # Replace with function body.
