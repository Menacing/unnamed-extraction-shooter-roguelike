extends BTDecorator

@export var cooldown_length:BBFloat

var timer:SceneTreeTimer
var is_child_running:= false

func _generate_name() -> String:
	return "%ss Variable Cooldown" % [cooldown_length]
	
func _setup() -> void:
	timer = scene_root.get_tree().create_timer(cooldown_length.get_value(scene_root,blackboard))
	pass

func _tick(delta: float) -> Status:
	if is_zero_approx(timer.time_left) or is_child_running:
		timer = scene_root.get_tree().create_timer(cooldown_length.get_value(scene_root,blackboard))
		var child_state:= get_child(0).execute(delta)
		is_child_running = (child_state == RUNNING)
		return child_state
	else:
		return FAILURE
