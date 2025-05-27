extends Node3D

@onready var extract_timer:Timer = Timer.new()
var extract_cooldown:float = 3.0
var extract_message_template:String = "Launching in %.3f"

func _ready():
	self.add_child(extract_timer)
	extract_timer.timeout.connect(_on_extract_timer_timeout)

func _physics_process(delta: float) -> void:
	if !extract_timer.is_stopped():
		EventBus.update_message.emit(str(get_instance_id()), extract_message_template % extract_timer.time_left)
	pass

func use(player:Player):
	if (HideoutManager.next_map or HideoutManager.return_to_previous_level) and extract_timer.is_stopped():
		extract_timer.start(extract_cooldown)
		EventBus.create_message.emit(str(get_instance_id()), extract_message_template % extract_cooldown, -1)		
	elif (HideoutManager.next_map or HideoutManager.return_to_previous_level) and !extract_timer.is_stopped():
		extract_timer.stop()
		EventBus.remove_message.emit(str(get_instance_id()))
	else:
		EventBus.create_message.emit(str(get_instance_id()), "Select next mission first", 5)
	
func _on_extract_timer_timeout():
	extract_timer.stop()
	EventBus.remove_message.emit(str(get_instance_id()))
	if HideoutManager.return_to_previous_level:
		await LevelManager.load_previous_level_async()
	else:
		await LevelManager.load_level_async(HideoutManager.next_map.level_path, true, HideoutManager.next_map)
	
