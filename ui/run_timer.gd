extends Label
class_name RunTimer

var total_time: float = 0.0

func _process(delta: float) -> void:
	
	if not HideoutManager.in_hideout:
		total_time += delta
		var formatted_time: String = convert_deltas_to_time_string(total_time)
		self.text = formatted_time

func convert_deltas_to_time_string(deltas: float) -> String:
	var minutes: int = int(deltas / 60)
	var seconds: int = int(deltas) % 60
	var hundredths: int = int((deltas - int(deltas)) * 100)
	
	return "%02d:%02d:%02d" % [minutes, seconds, hundredths]
