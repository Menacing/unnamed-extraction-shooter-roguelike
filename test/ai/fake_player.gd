extends Marker3D

@export var enemy:Enemy


func _on_timer_timeout() -> void:
	if enemy:
		var target_information = TargetInformation.new()
		target_information.last_known_position = self.global_position
		target_information.last_seen_mticks = Time.get_ticks_msec()
		target_information.target = self
		target_information.currently_has_los = true
		enemy.sensory_component.targets[self.get_instance_id()] = target_information

		enemy.state_chart.send_event("Suppressed")
	pass # Replace with function body.
